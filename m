From: Albert Pretorius <albertpretorius@yahoo.co.uk>
Subject: IPV6 loopback bound socket succeeds connecting to remote host
Date: Mon, 29 Nov 2010 10:55:46 +0000 (GMT)
Message-ID: <328335.88387.qm@web29006.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm11-vm0.bullet.mail.ird.yahoo.com ([77.238.189.218]:38314 "HELO
	nm11-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751872Ab0K2Kzr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Nov 2010 05:55:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
I found a problem with ipv6 when a UDP socket is bound to loopback (::1) and connecting to a remote address. The same applies to TCP.
Any data sent ends up on the remote host with a source address of loopback. The expected result of the connect should be EINVAL just like it is for ipv4.
Here is a possible patch that fixes this problem below. I tested it on 2.6.37-rc3 using a tool I put on http://www.gitorious.org/bindconnect

----8<----
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 99157b4..a0de66c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -927,6 +927,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 {
    int err;
    struct net *net = sock_net(sk);
+   struct net_device *dev_out;

    if (*dst == NULL)
        *dst = ip6_route_output(net, sk, fl);
@@ -934,6 +935,32 @@ static int ip6_dst_lookup_tail(struct sock *sk,
    if ((err = (*dst)->error))
        goto out_err_release;

+   dev_out = ip6_dst_idev(*dst)->dev;
+   if (dev_out && ipv6_addr_loopback(&fl->fl6_src) &&
+           !(dev_out->flags & IFF_LOOPBACK)) {
+       /*
+        * If socket is bound to loopback address but interface
+        * is not then it is invalid...
+        */
+       struct inet6_ifaddr *ifa;
+       struct inet6_dev *idev = in6_dev_get(dev_out);
+       err = -EINVAL;
+       if (idev) {
+           list_for_each_entry(ifa, &idev->addr_list, if_list)
+           {
+               /*
+                * ... unless the interface has the same address
+                */
+               if (ipv6_addr_equal(&ifa->addr, &fl->fl6_dst))
+                   err = 0;
+           }
+           in6_dev_put(idev);
+       }
+
+       if (err)
+           goto out_err_release;
+   }
+
    if (ipv6_addr_any(&fl->fl6_src)) {
        err = ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
                     &fl->fl6_dst,
---->8----

The bindconnect tool is build with just make and run like:

./obj/bindconnect -l ::1 9999 -r nnnn::nnn:nnnn:nnnn:nnnn%eth0 4444 -u
ERROR: Error occurred during connect() : Invalid argument

without the patch a UDP datagram is sent and TCP sends a SYN.

Please CC me personally as I am not subscribed to the mailing list.

thanks,
Albert Pretorius



      
