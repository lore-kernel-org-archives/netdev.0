From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix ovs_flow_key_update()
Date: Thu, 30 Mar 2017 15:22:15 +0200
Message-ID: <20170330152215.7b4f9703@griffin>
References: <1490832850-6012-1-git-send-email-yihung.wei@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: joe@ovn.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yi-Hung Wei <yihung.wei@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490832850-6012-1-git-send-email-yihung.wei@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Mar 2017 17:14:10 -0700, Yi-Hung Wei wrote:
> ovs_flow_key_update() is called when the flow key is invalid, and it is
> used to update and revalidate the flow key. Commit 329f45bc4f19
> ("openvswitch: add mac_proto field to the flow key") introduces mac_proto
> field to flow key and use it to determine whether the flow key is valid.
> However, the commit does not update the code path in ovs_flow_key_update()
> to revalidate the flow key which may cause BUG_ON() on execute_recirc().
> This patch addresses the aforementioned issue.

Good catch.

>  int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
>  {
> +	int res;
> +
> +	res = key_extract_mac_proto(skb);
> +	if (res < 0)
> +		return res;
> +	key->mac_proto = res;
> +
>  	return key_extract(skb, key);
>  }

But this should just reset the SW_FLOW_KEY_INVALID flag, there's no
need to recompute mac_proto.

Something like this:

 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 {
-	return key_extract(skb, key);
+	int res;
+
+	res = key_extract(skb, key);
+	if (!res)
+		key->mac_proto &= ~SW_FLOW_KEY_INVALID;
+	return res;
 }

Thanks,

 Jiri
