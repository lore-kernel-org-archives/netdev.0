From: Patrick McHardy <kaber@trash.net>
Subject: Usage of skb->cb and dev->xmit_lock
Date: Fri, 17 May 2002 01:58:53 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CE447BD.8040107@ws.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

I'm looking for some advice concerning two things.
First a little introduction:

I've written a software device used as a placeholder for qdiscs to 
perform ingress shaping / shaping over multiple interfaces. It feeds
itself packets marked by an iptables target through netfilter hooks.
For marked packets NF_QUEUE is returned and the packet is then enqueued
to the attached qdisc. The device's xmit function later reinjects them 
to the network stack.

Now my problems:
For reinjecting i need to keep the struct nf_info passed to my netfilter 
  queue handler. I therefore introduced a new field in struct sk_buff.
I don't really like this solution so i though of using skb->cb.
It says "This is owned by whoever has the skb queued ATM." which of 
course if not the device but the qdisc. But i haven't found any 
refernece to it in any qdisc so my question is: is it safe to use 
skb->cb in this altered code flow ?

The second problem arises when used with tunnels (only gre tested).
If packets going to a gre tunnel are redirected though imq and the gre 
packets themselves are redirected too then qdisc_restart starts 
complaining about the tunnel device beeing deadlooped. (why the tunnel 
device and not mine?). I thought releasing dev->xmit_lock before calling 
nf_reinject and grabing it back afterwards would solve the problem, but 
i'm not sure about the consequences ..
i guess on UP it doesn't matter, on SMP the worst thing i can imagine is 
   one processor waiting until the lock becomes free for grabbing it 
back if in the meantime another processor has taken it.
Can someone please enlighten me ? :)

Thanks for your help,
Patrick

PS: If you want to look at the source, it is available at 
http://luxik.cdi.cz/~patrick/imq
