From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch this
Date: Thu, 26 Sep 2002 23:33:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D93FBA6.6080905@candelatech.com>
References: <200209270100.FAA19447@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Hello!

>>+#ifdef CONFIG_NET_SENDTOSELF
>>+	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(skb->nh.iph->tos), sk->bound_dev_if))
>>+#else
>>  	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(skb->nh.iph->tos), 0))
>>+#endif
> 
> 
> This chunk is noop, sk here is a dummy socket internal to kernel,
> where sk->bound_dev_if is identical zero. Grep code to see
> what it is used for.

Ok, I took out my changes above and sure enough, it still seems to work.

I have a question though:  If this method is ever called to send an RST,
will it work?  It seems to me that it may not be routed correctly, but
I don't understand all the circumstances that would cause this method to
be called either...

> 
> The same ("noopness") is true about 90% of the patch. F.e. all the messing
> inside tcp with openreqs is noop.

What about this part, do you think it is not needed either?  It appeared
to me that w/out this, the sending socket and the receiving socket could hash
to the same thing, and so greatly confused themselves.  For instance,

src=1.2.3.4, port 9999, dst=1.2.3.5 port 9999

I believe I was seeing the first packet (SYN) from the originator being
delivered back to the socket that sent the SYN because no new socket on
the receiving side was created because the hash found one (it found the
sending one, unfortunately).


+        /* Will only take netdevice_id into the equation if neither are
+         * 0.  This should be backwards compatible with older code, and also
+         * let us connect to ourselves over external ports.  Otherwise, we
+         * get confused about which connection is the originator v/s the
+         * receiver of the open request. --Ben
+         */
  	for (prev = &lopt->syn_table[tcp_v4_synq_hash(raddr, rport)];
  	     (req = *prev) != NULL;
  	     prev = &req->dl_next) {
  		if (req->rmt_port == rport &&
  		    req->af.v4_req.rmt_addr == raddr &&
  		    req->af.v4_req.loc_addr == laddr &&
-		    TCP_INET_FAMILY(req->class->family)) {
+		    TCP_INET_FAMILY(req->class->family)
+#ifdef CONFIG_NET_SENDTOSELF
+                    && ((!netdevice_id) || (!req->bound_dev_if) ||
+                     (req->bound_dev_if == netdevice_id))) {
+#else
+                   ) {
+#endif


Thanks again,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
