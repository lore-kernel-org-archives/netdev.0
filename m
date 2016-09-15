From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Fri, 16 Sep 2016 00:01:26 +0300
Message-ID: <20160915210126.GC1867@uranus.lan>
References: <20160913171950.GC32643@uranus>
 <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
 <20160915202219.GB1867@uranus.lan>
 <f482796f-185e-a3b7-248c-20f1f39cb459@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34447 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751337AbcIOVBa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 17:01:30 -0400
Content-Disposition: inline
In-Reply-To: <f482796f-185e-a3b7-248c-20f1f39cb459@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 02:54:57PM -0600, David Ahern wrote:
> On 9/15/16 2:22 PM, Cyrill Gorcunov wrote:
> >> ss -K is not working. Socket lookup fails to find a match due to a protocol mismatch.
> >>
> >> haven't had time to track down why there is a mismatch since the kill uses the socket returned
> >> from the dump. Won't have time to come back to this until early next week.
> > 
> > Have you ran iproute2 patched? I just ran ss -K and all sockets get closed
> > (including raw ones), which actually kicked me off the testing machine sshd :/
> > 
> 
> 
> This is the patch I applied to iproute2; the change in your goo.gl link plus a debug to confirm the kill action is initiated by ss:
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 3b268d999426..4d98411738ea 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -2334,6 +2334,10 @@ static int show_one_inet_sock(const struct sockaddr_nl *addr,
>         if (diag_arg->f->f && run_ssfilter(diag_arg->f->f, &s) == 0)
>                 return 0;
> 
> +       if (diag_arg->f->kill) {
> +printf("want to kill:\n");
> +       err = inet_show_sock(h, &s, diag_arg->protocol);
> +       }
>         if (diag_arg->f->kill && kill_inet_sock(h, arg) != 0) {
>                 if (errno == EOPNOTSUPP || errno == ENOENT) {
>                         /* Socket can't be closed, or is already closed. */
> @@ -2631,6 +2635,10 @@ static int raw_show(struct filter *f)
> 
>         dg_proto = RAW_PROTO;
> 
> +if (!getenv("PROC_NET_RAW") && !getenv("PROC_ROOT") &&
> +inet_show_netlink(f, NULL, IPPROTO_RAW) == 0)
> +return 0;
> +
>         if (f->families&(1<<AF_INET)) {
>                 if ((fp = net_raw_open()) == NULL)
>                         goto outerr;
> 

Hmm. Weird. I'm running net-next kernel
---
[root@pcs7 ~]# /root/sock &
[1] 5108

This is a trivial program which opens raw sockets 

[root@pcs7 iproute2]# misc/ss -A raw
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
ESTAB      0      0                                         127.0.0.1:ipproto-255                                            127.0.0.10:ipproto-9090         
UNCONN     0      0                                        127.0.0.10:ipproto-255                                                     *:*                    
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
ESTAB      0      0                                               ::1:ipproto-255                                                   ::1:ipproto-9091         
UNCONN     0      0                                               ::1:ipproto-255                                                    :::*                    
[root@pcs7 iproute2]# 

[root@pcs7 iproute2]# misc/ss -K
Netid  State      Recv-Q Send-Q                             Local Address:Port                                              Peer Address:Port                
u_str  ESTAB      0      0                /var/run/dbus/system_bus_socket 18071                                                        * 16297                
u_str  ESTAB      0      0                    /run/systemd/journal/stdout 18756                                                        * 16188                
u_str  ESTAB      0      0                    /run/systemd/journal/stdout 23014                                                        * 23013                
u_str  ESTAB      0      0                                              * 18909                                                        * 16298                
u_str  ESTAB      0      0                /var/run/dbus/system_bus_socket 19154                                                        * 18163                
...
???    ESTAB      0      0                                      127.0.0.1:ipproto-255                                         127.0.0.10:ipproto-9090         
???    UNCONN     0      0                                     127.0.0.10:ipproto-255                                                  *:*                    
???    ESTAB      0      0                                            ::1:ipproto-255                                                ::1:ipproto-9091         
???    UNCONN     0      0                                            ::1:ipproto-255                                                 :::*            
---

Here I get kicked off the server. Login back

[cyrill@uranus ~] ssh root@pcs7 
Last login: Thu Sep 15 23:20:42 2016 from gateway
[root@pcs7 ~]# cd /home/iproute2/
[root@pcs7 iproute2]# misc/ss -A raw
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    

Maybe I do something wrong for testing?
