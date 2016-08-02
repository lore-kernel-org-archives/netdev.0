From: Brandon Cazander <brandon.cazander@multapplied.net>
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
Date: Tue, 2 Aug 2016 21:58:59 +0000
Message-ID: <BL2PR07MB23064A6351DD273B6F4F73E59E050@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <BL2PR07MB2306908C76E928619A24B52E9E0F0@BL2PR07MB2306.namprd07.prod.outlook.com>,<20160729132154.GB13634@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"edumazet@google.com" <edumazet@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0066.outbound.protection.outlook.com ([104.47.32.66]:45568
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752988AbcHCChS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 22:37:18 -0400
In-Reply-To: <20160729132154.GB13634@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>     Please try this patch, it makes it work for me again.
>       I decided to extend the existing snat support in xt_socket.c instead
>       of changing TPROXY target:

This fixes my example (with the DIVERT chain), but does not fix the two-line example you gave below. Another setup I have is also still broken as of this diff (similarly, there is a rule in nat PREROUTING that goes to a chain with the TPROXY rule).

>     No need, this reproduces easily with this two-line ruleset:
>     
>     -t nat -A PREROUTING -d 192.168.7.20/32 -i eth0 -j DNAT --to-destination 192.168.8.1
>     -t mangle -A PREROUTING -p tcp -m tcp --dport 8080 -j TPROXY --on-port 9876 --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1

As I said above, this doesn't work, but this does:

-t nat -A PREROUTING -d 192.168.7.20/32 -i eth0 -j DNAT --to-destination 192.168.8.1
-t mangle -N DIVERT
-t mangle -A PREROUTING -p tcp -m socket -j DIVERT
-t mangle -A DIVERT -j MARK --set-mark 1
-t mangle -A DIVERT -j ACCEPT
-t mangle -A PREROUTING -p tcp -m tcp --dport 8080 -j TPROXY --on-port 9876 --on-ip 0.0.0.0 --tproxy-mark 0x1/0x1

Thanks for looking at this so quickly.



From: Florian Westphal <fw@strlen.de>
Sent: Friday, July 29, 2016 6:21 AM
To: Brandon Cazander
Cc: netdev@vger.kernel.org; edumazet@google.com
Subject: Re: PROBLEM: TPROXY and DNAT broken (bisected to 079096f103fa)
    
Brandon Cazander <brandon.cazander@multapplied.net> wrote:
> * When it fails, no traffic hits the WEBSERVER. A tcpdump on the bad kernel shows:
>     root@dons-qemu-new-kernel:~# tcpdump -niany tcp and port 8080
>     tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
>     listening on any, link-type LINUX_SLL (Linux cooked), capture size 65535 bytes
>     16:42:31.551952 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [S], seq 3793582216, win 29200, options [mss 1460,sackOK,TS val 632068656 ecr 0,nop,wscale 7], length 0
>     16:42:31.551988 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [S.], seq 4042636216, ack 3793582217, win 28960, options [mss 1460,sackOK,TS val 745382 ecr 632068656,nop,wscale 7], length 0
>     16:42:31.552222 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [.], ack 1, win 229, options [nop,nop,TS val 632068657 ecr 745382], length 0
>     16:42:31.552238 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [R], seq 4042636217, win 0, length 0
>     16:42:31.552246 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [P.], seq 1:78, ack 1, win 229, options [nop,nop,TS val 632068657 ecr 745382], length 77
>     16:42:31.552251 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [R], seq 4042636217, win 0, length 0
>     16:42:32.551668 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [S.], seq 4042636216, ack 3793582217, win 28960, options [mss 1460,sackOK,TS val 745632 ecr 632068656,nop,wscale 7], length 0
>     16:42:32.551925 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [R], seq 3793582217, win 0, length 0
>     16:42:34.551668 IP 42.0.1.1.8080 > 10.100.0.206.35562: Flags [S.], seq 4042636216, ack 3793582217, win 28960, options [mss 1460,sackOK,TS val 746132 ecr 632068656,nop,wscale 7], length 0
>     16:42:34.551995 IP 10.100.0.206.35562 > 42.0.1.1.8080: Flags [R], seq 3793582217, win 0, length 0

Please try this patch, it makes it work for me again.
I decided to extend the existing snat support in xt_socket.c instead
of changing TPROXY target:

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -144,6 +144,44 @@ static bool xt_socket_sk_is_transparent(struct sock *sk)
         }
 }
 
+static void get_lookup_daddr(const struct sk_buff *skb, u32 *daddr, u16 *dport)
+{
+#ifdef XT_SOCKET_HAVE_CONNTRACK
+       const struct iphdr *iph = ip_hdr(skb);
+       enum ip_conntrack_info ctinfo;
+       enum ip_conntrack_dir dir;
+       struct nf_conn const *ct;
+
+       /* Do the lookup with the original socket address in
+        * case this is a packet of an SNAT-ted connection.
+        */
+       ct = nf_ct_get(skb, &ctinfo);
+       if (!ct || nf_ct_is_untracked(ct))
+               return;
+
+       if ((ct->status & IPS_SRC_NAT_DONE) == 0)
+               return;
+
+       dir = CTINFO2DIR(ctinfo);
+       switch (iph->protocol) {
+       case IPPROTO_ICMP:
+               if (ctinfo != IP_CT_RELATED_REPLY)
+                       return;
+               break;
+       case IPPROTO_TCP:
+               *dport = ct->tuplehash[!dir].tuple.src.u.tcp.port;
+               break;
+       case IPPROTO_UDP:
+               *dport = ct->tuplehash[!dir].tuple.src.u.udp.port;
+               break;
+       default:
+               return;
+       }
+
+       *daddr = ct->tuplehash[!dir].tuple.src.u3.ip;
+#endif
+}
+
 static struct sock *xt_socket_lookup_slow_v4(struct net *net,
                                              const struct sk_buff *skb,
                                              const struct net_device *indev)
@@ -154,10 +192,6 @@ static struct sock *xt_socket_lookup_slow_v4(struct net *net,
         __be32 uninitialized_var(daddr), uninitialized_var(saddr);
         __be16 uninitialized_var(dport), uninitialized_var(sport);
         u8 uninitialized_var(protocol);
-#ifdef XT_SOCKET_HAVE_CONNTRACK
-       struct nf_conn const *ct;
-       enum ip_conntrack_info ctinfo;
-#endif
 
         if (iph->protocol == IPPROTO_UDP || iph->protocol == IPPROTO_TCP) {
                 struct udphdr _hdr, *hp;
@@ -185,25 +219,7 @@ static struct sock *xt_socket_lookup_slow_v4(struct net *net,
                 return NULL;
         }
 
-#ifdef XT_SOCKET_HAVE_CONNTRACK
-       /* Do the lookup with the original socket address in
-        * case this is a reply packet of an established
-        * SNAT-ted connection.
-        */
-       ct = nf_ct_get(skb, &ctinfo);
-       if (ct && !nf_ct_is_untracked(ct) &&
-           ((iph->protocol != IPPROTO_ICMP &&
-             ctinfo == IP_CT_ESTABLISHED_REPLY) ||
-            (iph->protocol == IPPROTO_ICMP &&
-             ctinfo == IP_CT_RELATED_REPLY)) &&
-           (ct->status & IPS_SRC_NAT_DONE)) {
-
-               daddr = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;
-               dport = (iph->protocol == IPPROTO_TCP) ?
-                       ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.tcp.port :
-                       ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u.udp.port;
-       }
-#endif
+       get_lookup_daddr(skb, &daddr, &dport);
 
         return xt_socket_get_sock_v4(net, data_skb, doff, protocol, saddr,
                                      daddr, sport, dport, indev);
    
