From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: Linux IP stack change to obtain TTL min/max/avg
Date: Wed, 31 Dec 2008 14:34:19 +0100
Message-ID: <20081231133419.GA2388@uranus.ravnborg.org>
References: <21230026.post@talk.nabble.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: mpk_india <mpk_india@yahoo.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756549AbYLaNcx@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <21230026.post@talk.nabble.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev is a much better place for this - added.

	Sam

On Wed, Dec 31, 2008 at 03:20:53AM -0800, mpk_india wrote:
> 
> Hello All,
> 
> I am trying to modify the linux ip stack to get the avg/min/max of the TTL
> value (in trasport layer) from the received UDP packet. I have modifed the
> 2.6.28 kernel for this and added new setsockopt flags as IP_RECVTTL_AVG,
> IP_RECVTLL_MIN, IP_RECVTTL_MAX.
> 
> Please see below changes I have made to do this:
> 
> 1. Inside "in.h" file Added following macros
> #define IP_RECVTTL_AVG	20
> #define IP_RECVTTL_MIN	21
> #define IP_RECVTTL_MAX	22
> 
> 2. Inside "inet_sock.h" in struct inet_sock {
> added 3 variables
> __s16	 uc_ttl_avg;
> __s16	 uc_ttl_min;
> __s16	 uc_ttl_max;
> 
> 3. In ipv4/udp.c added following peice of code
> sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
> if (sk != NULL) {
> 
> #if 1	// Changes to get TTL stats..Start
> struct iphdr *iph;
> struct inet_sock *inet;
> inet = inet_sk(sk);
> iph = ip_hdr(skb);
> inet->uc_ttl_avg = (iph->ttl + inet->uc_ttl_avg)>>1;
> if (inet->uc_ttl_max < iph->ttl)
> inet->uc_ttl_max = iph->ttl;
> if (inet->uc_ttl_min > iph->ttl)
> inet->uc_ttl_min = iph->ttl;
> #endif	// Changes to get TTL stats..Start
> 
> int ret = udp_queue_rcv_skb(sk, skb);
> sock_put(sk);
> 
> 4. Changes inside "ip_sockglue.c" file
> 
> static void ip_cmsg_recv_ttl_avg(struct msghdr *msg, struct sk_buff *skb)
> {
> struct inet_sock *inet = inet_sk(skb->sk);
> int ttl = inet->uc_ttl_avg;
> printk(KERN_DEBUG "***<recv ttl avg () is called -- value = %d***\n", ttl);
> put_cmsg(msg, SOL_IP, IP_TTL, sizeof(int), &ttl);
> }
> 
> static void ip_cmsg_recv_ttl_max(struct msghdr *msg, struct sk_buff *skb)
> {
> struct inet_sock *inet = inet_sk(skb->sk);
> int ttl = inet->uc_ttl_max;
> printk(KERN_DEBUG "***<recv ttl max () is called -- value = %d***\n", ttl);
> put_cmsg(msg, SOL_IP, IP_TTL, sizeof(int), &ttl);
> }
> 
> static void ip_cmsg_recv_ttl_min(struct msghdr *msg, struct sk_buff *skb)
> {
> struct inet_sock *inet = inet_sk(skb->sk);
> int ttl = inet->uc_ttl_min;
> printk(KERN_DEBUG "***<recv ttl min () is called -- value = %d***\n", ttl);
> put_cmsg(msg, SOL_IP, IP_TTL, sizeof(int), &ttl);
> }
> 
> void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
> {
> .
> .
> .
> .
> #if 1	// Changes to get TTL stats..Start
> if (flags & 1)
> ip_cmsg_recv_ttl_avg(msg, skb);
> if ((flags>>=1) == 0)
> return;
> if (flags & 1)
> ip_cmsg_recv_ttl_min(msg, skb);
> if ((flags>>=1) == 0)
> return;
> if (flags & 1)
> ip_cmsg_recv_ttl_max(msg, skb);
> #endif	// Changes to get TTL stats..Start
> 
> }
> 
> inside do_ip_setsockopt() added following code
> 
> #if 1	// Changes to get TTL stats..Start
> case IP_RECVTTL_AVG:
> if (val)
> inet->cmsg_flags |= IP_CMSG_TTL_AVG;
> else
> inet->cmsg_flags &= ~IP_CMSG_TTL_AVG;
> break;
> case IP_RECVTTL_MIN:
> if (val)
> inet->cmsg_flags |= IP_CMSG_TTL_MIN;
> else
> inet->cmsg_flags &= ~IP_CMSG_TTL_MIN;
> break;
> case IP_RECVTTL_MAX:
> if (val)
> inet->cmsg_flags |= IP_CMSG_TTL_MAX;
> else
> inet->cmsg_flags &= ~IP_CMSG_TTL_MAX;
> break;
> #endif	// Changes to get TTL stats..End
> 
> =================================================================
> 
> I have compiled this and written the udp client server to test this. 
> 
> 
> In my client application i am sending 64 packets with some dummy message. In
> server I have used the recvmsg() and setsockopt() to test these changes as
> below:
> 
> setsockopt(serverfd, IPPROTO_IP, IP_OPTIONS, NULL, 0);
> if (setsockopt (serverfd,IPPROTO_IP, IP_RECVTTL_AVG, &ttl,ttlSize)<0) {
> 
> printf ("Error occured in setsockopt\n");
> exit(1);
> }
> 
> now if i do the recvmsg 64 times after recvfrom in my server code it gives
> me proper ttl avg values.. but i do not want to seek this values for every
> packet i receive.. i want them once for all sent 64 udp packets.. the same
> recvmsg fails if i doit single recvmsg after 64 received packets..
> 
> 
> Can anyone tell about what i am doing wrong in the present scenario?
> 
> Thanks in advance
> mpk
> -- 
> View this message in context: http://www.nabble.com/Linux-IP-stack-change-to-obtain-TTL-min-max-avg-tp21230026p21230026.html
> Sent from the linux-kernel mailing list archive at Nabble.com.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
