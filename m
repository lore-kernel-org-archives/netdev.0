From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [net-next RFC v2] net_cls: traffic counter based on classification
 control cgroup
Date: Tue, 27 Nov 2012 14:02:26 +0100
Message-ID: <50B4B9E2.4030200@monom.org>
References: <50B49C6C.8030604@samsung.com> <50B49DEA.7010000@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kyungmin Park <kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
To: Alexey Perevalov <a.perevalov-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50B49DEA.7010000-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alexey,

On 27.11.2012 12:03, Glauber Costa wrote:
> On 11/27/2012 02:56 PM, Alexey Perevalov wrote:
>> Hello.
>>
>> It's second version of patch I already sent to netdev.
>>
>> The main goal of this patch it's counting traffic for process placed to
>> net_cls cgroup (ingress and egress).
>> It's based on res_counters and holds counter per network interfaces.
>>
>> Description of patch.
>> It handles packets in net/core/dev.c for egress and in
>> /net/ipv4/tcp.c|udp.c for ingress.
>> These places were chosen because we need to know also network interface.
>>
>> Cgroup fs interface provides following files additional to existing
>> net_cls files:
>> net_cls.ifacename.usage_in_bytes
>> Containing rcv/snd lines.
>> Also this patch adds to net_cls ability to handle a network device
>> registration.
>>
>> It could be included or excluded in compile time.
>> I moved the menu entry for "Control group classifier" from network/QoS to
>> General Option/Control Group.
>>
>> I'm waiting for you comments.
>>
> 
> Daniel Wagner is working on something a lot similar.

Yes, basically what I try to do is explained by this excellent article

https://lwn.net/Articles/523058/

The short version: Per application routing and statistics. 

I have two PoC implementation doing this. Both implementation have the same key
idea which is to set SO_MARK per application. The routing and statistics would 
then be done by a bunch iptables rules.

In the first implementation extends net_cls to set SO_MARK:

void sock_update_classid(struct sock *sk, struct task_struct *task)
 {
        u32 classid;
+       u32 mark;
 
        classid = task_cls_classid(task);
        if (classid != sk->sk_classid)
                sk->sk_classid = classid;
+
+       mark = task_cls_mark(task);
+       if (mark != sk->sk_mark)
+               sk->sk_mark = mark;
 }

The second implementation is adding a new iptables matcher which matches
on LSM contexts. Then you can do something like this:

iptables -t mangle -A OUTPUT -m secmark --secctx unconfined_u:unconfined_r:foo_t:s0-s0:c0.c1023 -j MARK --set-mark 200

> Maybe you should be in contact, in case you are not yet.
> 
> A few general comments:
> 1) res_counters are incredibly expensive. If you are more interested in
> counting than you are in limiting, they may not be your best choice.
> 
> 2) When Daniel exposed his use case to me, it gave me the impression
> that "counting traffic" is something that is totally doable by having a
> dedicated interface in a separate namespace. Basically, we already count
> traffic (rx and tx) for all interfaces anyway, so it suggests that it
> could be an interesting way to see the problem.

Moving applications into separate net namespaces is for sure a valid solution. 
Though there is a one drawback in this approach. The namespaces need to be 
attached to a bridge and then some NATting. That means every application
would get it's own IP address. This might be okay for your certain use
cases but I am still trying to work around this. Glauber and I had some
discussion about this and he suggested to allow the physical networking
device to be attached to several namespaces (e.g. via macvlan). Every
namespace would get the same IP address. Unfortunately, this would result in
the same mess as several physical devices on a network get the same
IP address assigned. 

> AFAIK, Daniel is still measuring this. But it would be great to know if
> that could work for your use case as well.

I have not started to measure :(

cheers,
daniel
