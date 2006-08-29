From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/6] NetLabel: correctly initialize the NetLabel fields
Date: Tue, 29 Aug 2006 13:56:00 -0400
Message-ID: <44F47FB0.5000700@hp.com>
References: <20060829144251.452774000@hp.com> <20060829144444.202106000@hp.com> <Pine.LNX.4.64.0608291248410.29142@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:35798 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S965182AbWH2R4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 13:56:05 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0608291248410.29142@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Tue, 29 Aug 2006, paul.moore@hp.com wrote:
>>+void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
>>+				     int family)
>>+{
>>+        if (family == PF_INET)
> 
> No tab. 

I see you already ack'd this patch, should I resubmit with the tab
correction or just leave it alone?

>>+		ssec->nlbl_state = NLBL_REQUIRE;
>>+	else
>>+		ssec->nlbl_state = NLBL_UNSET;
>>+}
>  
> It doesn't look like this code handles ipv4 packets mapped on ipv6 
> sockets.  See the test elsewhere in the SELinux code:
> 
> 	if (family == PF_INET6 && skb->protocol == ntohs(ETH_P_IP))

This is an issue which I am still thinking about, but I haven't devoted
to much time to it because in the one example case I have tried
everything works as expected.

Example case:

1. Configure NetLabel so that packets are labeled with CIPSO
2. Ensure SSH is listening for both IPv4 and IPv6 connections and
restart the daemon
3. Connect to the SSH daemon using IPv4

I haven't looked at the sshd code enough in detail to see what it is
doing exactly but simply running 'netstat -nl' shows that sshd is
listening for connections with an IPv6 socket (at least it is listening
on port ':::22').  Once the connection is established the daemon
continues to use an IPv6 socket, '::ffff:127.0.0.1:22', whereas the
client uses a traditional IPv4 socket.  Sniffing the connection
indicates that both directions of network traffic are labeled with the
correct CIPSO tags.

On the receive side in selinux_socket_sock_rcv_skb() the socket's IP
address family is not consulted, only the SELinux socket class and the
skbuff's CIPSO tag if present.

On the outbound side, yes, we only NetLabel sockets which are PF_INET
but I didn't think I could set an IPv4 option on a PF_INET6 socket can
I?  It just sounds wrong ...

> Also, can you verify that you've tested these fixes and that they resolve 
> all issues that you've encountered?

I have verified that this patchset fixes all the issues that I've
encountered.  In addition I have run the patches overnight on a test
machine while hitting the machine pretty hard and I have not noticed any
other problems or regressions.

-- 
paul moore
linux security @ hp
