From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: reduce RECURSION_LIMIT to 8
Date: Tue, 12 Jan 2016 02:48:42 +0100
Message-ID: <56945B7A.6010601@stressinduktion.org>
References: <1452188453-5523-1-git-send-email-hannes@stressinduktion.org>
 <CAOrHB_AWdZw1XDmxVU=bDh=gB2M3cnXUC8MyXCnV1YVjZEAsKw@mail.gmail.com>
 <56939EEF.70403@stressinduktion.org>
 <CAOrHB_DKMW6VoVbu1yvHRQRk92w-uUZWaGQURyRxhO=GaOPXsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:55498 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762053AbcALBss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 20:48:48 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 9A6A820FD0
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 20:48:47 -0500 (EST)
In-Reply-To: <CAOrHB_DKMW6VoVbu1yvHRQRk92w-uUZWaGQURyRxhO=GaOPXsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12.01.2016 01:36, pravin shelar wrote:
> On Mon, Jan 11, 2016 at 4:24 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 11.01.2016 07:38, pravin shelar wrote:
>>>
>>> On Thu, Jan 7, 2016 at 9:40 AM, Hannes Frederic Sowa
>>> <hannes@stressinduktion.org> wrote:
>>>>
>>>> When RECURSION_LIMIT was first introduced, Eric proposed a limit of 3.
>>>> This limit was later raised to 10 by DaveM. Nowadays it is observed that
>>>> configuraion errors in openvswitch cause the STACK_END_MAGIC to be
>>>> overwritten shortly after 9 recursion.
>>>>
>>> Major user of stack space in OVS is sw_flow_key in
>>> ovs_vport_receive(). With recent features like IPv6 tunnel support we
>>> have increased the size of the flow-key which could have caused the
>>> stack overflow sooner.
>>> One way to avoid using stack in subsequent recursive call is to use
>>> per-cpu storage for the sw_flow_key object. This is already done for
>>> OVS recursive actions, so we can expand on that facility.
>>
>>
>> Hmmm. This already came up. I think the difficulty is that ovs_vport_receive
>> can be called from actions again with skb_cloned skb before the original's
>> skb callstack is actually finished. Data in the percpu area would be
>> overwritten while still being used. It would need some more logic IMHO.
>>
> You can have stack of flow-keys and allocate a flow-key for each recursive call.

Hmm, I came up with something like that but the other day I find it
unpleasant and think that the kmalloc might anyway end up in the fast
path:

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 31cbc8c5c7db82..af9c94c732ce56 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -426,6 +426,9 @@ u32 ovs_vport_find_upcall_portid(const struct vport 
*vport, struct sk_buff *skb)
  	return ids->ids[ids_index];
  }

+static DEFINE_PER_CPU(struct sw_flow_key, pcpu_key);
+static DEFINE_PER_CPU(int, ovs_recursion);
+
  /**
   *	ovs_vport_receive - pass up received packet to the datapath for 
processing
   *
@@ -439,9 +442,19 @@ u32 ovs_vport_find_upcall_portid(const struct vport 
*vport, struct sk_buff *skb)
  int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
  		      const struct ip_tunnel_info *tun_info)
  {
-	struct sw_flow_key key;
+	struct sw_flow_key *key;
  	int error;

+	if (__this_cpu_inc_return(ovs_recursion) == 1) {
+		key = raw_cpu_ptr(&pcpu_key);
+	} else {
+		key = kmalloc(sizeof(*key), GFP_ATOMIC);
+		if (!key) {
+			__this_cpu_dec(ovs_recursion);
+			return -ENOMEM;
+		}
+	}
+
  	OVS_CB(skb)->input_vport = vport;
  	OVS_CB(skb)->mru = 0;
  	if (unlikely(dev_net(skb->dev) != ovs_dp_get_net(vport->dp))) {
@@ -454,12 +467,15 @@ int ovs_vport_receive(struct vport *vport, struct 
sk_buff *skb,
  	}

  	/* Extract flow from 'skb' into 'key'. */
-	error = ovs_flow_key_extract(tun_info, skb, &key);
+	error = ovs_flow_key_extract(tun_info, skb, key);
  	if (unlikely(error)) {
  		kfree_skb(skb);
-		return error;
+		goto out;
  	}
-	ovs_dp_process_packet(skb, &key);
+	ovs_dp_process_packet(skb, key);
+out:
+	if (__this_cpu_dec_return(ovs_recursion) > 0)
+		kfree(key);
  	return error;
  }
  EXPORT_SYMBOL_GPL(ovs_vport_receive);


>> What are recursive actions in ovs? I couldn't find any use of pcpu data in
>> there? Thanks! :)
>>
> There are couple of recursive actions in OVS, e.g.
> OVS_ACTION_ATTR_RECIRC. But it is implemented by using per-cpu
> flow-key stack to avoid recursive function call.

Ahh, the deferred_action stuff. I understand. So the idea would be to
lift even the first entry point to deferred_action a like?

This sounds like it could work but I fear we should find a solution
for stable, as this seems like a bit more work.

Thanks,
Hannes
