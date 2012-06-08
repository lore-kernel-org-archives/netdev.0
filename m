From: Saurabh <saurabh.mohan@vyatta.com>
Subject: [PATCH 01/02] iproute2: VTI support for ip tunnel command.
Date: Fri, 8 Jun 2012 10:33:13 -0700
Message-ID: <20120608173313.GA11996@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36218 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762279Ab2FHRd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2012 13:33:26 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id C1BEB14103AB
	for <netdev@vger.kernel.org>; Fri,  8 Jun 2012 10:33:25 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Dq-loWB3+iUU for <netdev@vger.kernel.org>;
	Fri,  8 Jun 2012 10:33:24 -0700 (PDT)
Received: from localhost (eng-dhcp-126.vyatta.com [10.3.0.126])
	by mail.vyatta.com (Postfix) with ESMTPSA id 9AD6714103AC
	for <netdev@vger.kernel.org>; Fri,  8 Jun 2012 10:33:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Configure VTI using 'ip tunnel'.

Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>

---
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 38ccd87..c054b7e 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -33,7 +33,7 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip tunnel { add | change | del | show | prl | 6rd } [ NAME ]\n");
-	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ] [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap | esp } ] [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "          [ prl-default ADDR ] [ prl-nodefault ADDR ] [ prl-delete ADDR ]\n");
 	fprintf(stderr, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
@@ -94,6 +94,12 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				}
 				p->iph.protocol = IPPROTO_IPV6;
 				isatap++;
+			} else if (strcmp(*argv, "esp") == 0) {
+				if (p->iph.protocol && p->iph.protocol != IPPROTO_ESP) {
+					fprintf(stderr, "You managed to ask for more than one tunnel mode.\n");
+					exit(-1);
+				}
+				p->iph.protocol = IPPROTO_ESP;
 			} else {
 				fprintf(stderr,"Cannot guess tunnel mode.\n");
 				exit(-1);
@@ -220,6 +226,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 		else if (memcmp(p->name, "isatap", 6) == 0) {
 			p->iph.protocol = IPPROTO_IPV6;
 			isatap++;
+		} else if (memcmp(p->name, "esp", 3) == 0) {
+			p->iph.protocol = IPPROTO_ESP;
 		}
 	}
 
@@ -274,8 +282,10 @@ static int do_add(int cmd, int argc, char **argv)
 		return tnl_add_ioctl(cmd, "gre0", p.name, &p);
 	case IPPROTO_IPV6:
 		return tnl_add_ioctl(cmd, "sit0", p.name, &p);
+	case IPPROTO_ESP:
+		return tnl_add_ioctl(cmd, "ip_vti0", p.name, &p);
 	default:
-		fprintf(stderr, "cannot determine tunnel mode (ipip, gre or sit)\n");
+		fprintf(stderr, "cannot determine tunnel mode (ipip, gre, esp or sit)\n");
 		return -1;
 	}
 	return -1;
@@ -295,6 +305,8 @@ static int do_del(int argc, char **argv)
 		return tnl_del_ioctl("gre0", p.name, &p);
 	case IPPROTO_IPV6:
 		return tnl_del_ioctl("sit0", p.name, &p);
+	case IPPROTO_ESP:
+		return tnl_del_ioctl("ip_vti0", p.name, &p);
 	default:
 		return tnl_del_ioctl(p.name, p.name, &p);
 	}
@@ -487,6 +499,9 @@ static int do_show(int argc, char **argv)
 	case IPPROTO_IPV6:
 		err = tnl_get_ioctl(p.name[0] ? p.name : "sit0", &p);
 		break;
+	case IPPROTO_ESP:
+		err = tnl_get_ioctl(p.name[0] ? p.name : "ip_vti0", &p);
+		break;
 	default:
 		do_tunnels_list(&p);
 		return 0;
diff --git a/ip/tunnel.c b/ip/tunnel.c
index b176d3f..8544581 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -52,6 +52,9 @@ const char *tnl_strproto(__u8 proto)
 	case IPPROTO_IPV6:
 		strcpy(buf, "ipv6");
 		break;
+	case IPPROTO_ESP:
+		strcpy(buf, "esp");
+		break;
 	case 0:
 		strcpy(buf, "any");
 		break;
