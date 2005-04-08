From: "Michael Richardson" <mcr@sandelman.ottawa.on.ca>
Subject: [Openswan dev] tcpdump and UDP encap on 2.6
Date: Fri, 08 Apr 2005 14:27:33 -0400
Message-ID: <21730.1112984853@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============56073481556368487=="
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@openswan.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@openswan.org>
List-Help: <mailto:dev-request@openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=subscribe>
Sender: dev-bounces@openswan.org
Errors-To: dev-bounces@openswan.org
List-Id: netdev.vger.kernel.org

--===============56073481556368487==
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--=-=-=


Herbert, I think that there is a bug/mis-feature in net/ipv4/udp.c.
The skb is modified without having checked if it is in fact shared/cloned.
The result is that tcpdump sees the wrong thing. This can be confusing:

First, get the latest tcpdump 3.9 beta (-096), which decodes UDP port
4500 packets. 

If I tcpdump on the incoming interface, without the ESP_IN_UDP option
set (openswan "ikeping" has an option to turn this on):

west:/testing/klips/west-natt-01# jobs
[2]-  Running                 tcpdump-3.9 -i eth1 -n -p &
[3]+  Running                 ipsec ikeping --listen --ikeport 4500 &
west:/testing/klips/west-natt-01# received 36() packet from 192.1.2.23/4500 of len: 116
        rcookie=78563412_0f000000 icookie=353bc42c_e2464cf2 msgid=8cf7b22e
        np=239  version=13.7    xchg=(36)
18:11:00.673351 IP 192.1.2.23.4500 > 192.1.2.45.4500: UDP-encap: ESP(spi=0x12345678,seq=0xf), length 116

I'm clearly getting an UDP encapsulated packet.

west:/testing/klips/west-natt-01# jobs
[2]-  Running                 tcpdump-3.9 -i eth1 -n -p &
[3]+  Running                 ipsec ikeping --listen --ikeport 4500 --nat-t &

west:/testing/klips/west-natt-01# 
18:12:01.795291 IP 192.1.2.23 > 192.1.2.45: ESP(spi=0x11941194,seq=0x7c0000), length 116
    
Notice how the packet has been mangled before being passed to tcpdump.
This is a problem for anyone trying to debug what's going on.

I think that this fixes the problem. I must admit to being a bit
ignorant as to which PRIO might be appropriate here. Also is there a
good FAQ on the difference between cloned SKBs vs shared SKBs? 

--- /distros/kernel/linux-2.6.11.2/net/ipv4/udp.c	2005-03-09 03:11:09.000000000 -0500
+++ linux/net/ipv4/udp.c	2005-04-08 14:22:53.000000000 -0400
@@ -897,8 +897,9 @@
  *	0  if we should drop this packet
  * 	-1 if it should get processed by xfrm4_rcv_encap
  */
-static int udp_encap_rcv(struct sock * sk, struct sk_buff *skb)
+static int udp_encap_rcv(struct sock * sk, struct sk_buff **pskb)
 {
+	struct sk_buff *skb = *pskb;
 #ifndef CONFIG_XFRM
 	return 1; 
 #else
@@ -968,11 +969,14 @@
 	 * transport header to point to ESP.  Keep UDP on the stack
 	 * for later.
 	 */
+	skb = skb_unshare(skb, 0);
 	skb->h.raw = skb_pull(skb, len);
 
 	/* modify the protocol (it's ESP!) */
 	iph->protocol = IPPROTO_ESP;
 
+	*pskb = skb;
+
 	/* and let the caller know to send this into the ESP processor... */
 	return -1;
 #endif
@@ -1010,7 +1014,7 @@
 		 */
 		int ret;
 
-		ret = udp_encap_rcv(sk, skb);
+		ret = udp_encap_rcv(sk, &skb);
 		if (ret == 0) {
 			/* Eat the packet .. */
 			kfree_skb(skb);




    

    




--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iQCVAwUAQlbNFYqHRg3pndX9AQF+6AQA6CDPtnb+JDg4z8GFjjT3qxGvQfdOxn5y
lhV8XeN53hStUK8xYbdLbBv1emRyaYXGMxy+xCY85U0xDLvsn4HkjFLDWdnP4Cb3
qkVuVs2UHtIeY0RAniAcjiTclWeBN8nGep2WYnwLXIwCVp5yUL8la5Ff0YpC3V8s
Z5BUY4l2gk0=
=2boW
-----END PGP SIGNATURE-----
--=-=-=--

--===============56073481556368487==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Dev mailing list
Dev@openswan.org
http://lists.openswan.org/mailman/listinfo/dev

--===============56073481556368487==--
