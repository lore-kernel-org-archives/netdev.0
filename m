From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Patch: minor nit in ip_options_compile()
Date: Fri, 21 Mar 2003 19:56:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200303211956.50921.niv@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In the following else clause, we check for opt->is_data, which 
should always be set for this case, and if not, current code will
lead to a null ptr dereference because skb is always null in 
this case..

Figured its better to fall down to returning EINVAL..
Look reasonable? 

thanks,
Nivedita


--- /usr/src/linux-2.5.65/net/ipv4/ip_options.c	Mon Mar 17 13:44:21 2003
+++ /usr/src/linux-2.5.65ref1/net/ipv4/ip_options.c	Fri Mar 21 18:16:05 2003
@@ -245,7 +245,7 @@
 int ip_options_compile(struct ip_options * opt, struct sk_buff * skb)
 {
 	int l;
-	unsigned char * iph;
+	unsigned char * iph = NULL;
 	unsigned char * optptr;
 	int optlen;
 	unsigned char * pp_ptr = NULL;
@@ -259,7 +259,9 @@
 		optptr = iph + sizeof(struct iphdr);
 		opt->is_data = 0;
 	} else {
-		optptr = opt->is_data ? opt->__data : (unsigned char*)&(skb->nh.iph[1]);
+		/* Only caller here is ip_options_get(), sets up opt, no skb */  
+		if ((optptr = opt->__data) == 0)
+			goto error; 
 		iph = optptr - sizeof(struct iphdr);
 	}
 
