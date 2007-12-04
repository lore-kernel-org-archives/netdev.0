From: Simon Arlott <simon@fire.lp0.eu>
Subject: sockets affected by IPsec always block (2.6.23)
Date: Tue, 04 Dec 2007 18:53:19 +0000
Message-ID: <4755A21F.2020407@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:44293 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754478AbXLDSxX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 13:53:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If I have a IPsec rule like:
	spdadd 192.168.7.8 1.2.3.4 any -P out ipsec esp/transport//require;
(i.e. a remote host 1.2.3.4 which will not respond)

Then any attempt to communicate with 1.2.3.4 will block, even when using non-blocking sockets:

socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 3
setsockopt(3, SOL_SOCKET, SO_LINGER, {onoff=1, linger=0}, 8) = 0
setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
fcntl64(3, F_GETFL)                     = 0x2 (flags O_RDWR)
fcntl64(3, F_SETFL, O_RDWR|O_NONBLOCK)  = 0 <-- non-blocking socket
connect(3, {sa_family=AF_INET, sin_port=htons(22), sin_addr=inet_addr("1.2.3.4")}, 16 <-- blocked connect()

[277657.564773] netcat        S b06bcf20     0  9450   9449
[277657.564785]        c8d51d28 00200046 00200046 b06bcf20 00200286 c8d51d14 00200286 c8d51d84
[277657.564814]        b06bcf20 c8d51d28 b013680b c8d51d84 eeae8800 c8d51d78 c8d51dd0 b04d3fc5
[277657.564843]        c8d51da4 00000002 00000001 ede87284 00000002 00000040 e9318ac0 db3f20a0
[277657.564874] Call Trace:
[277657.564881]  [<b04d3fc5>] __xfrm_lookup+0x2f5/0x510
[277657.564905]  [<b0494f9e>] ip_route_output_flow+0x4e/0x80
[277657.564919]  [<b04af303>] tcp_v4_connect+0x183/0x6d0
[277657.564934]  [<b04beaf2>] inet_stream_connect+0x122/0x1c0
[277657.564949]  [<b0471c8e>] sys_connect+0x9e/0xd0
[277657.564963]  [<b0472785>] sys_socketcall+0xa5/0x230
[277657.564973]  [<b01042ba>] syscall_call+0x7/0xb
[277657.564984]  =======================

I had a process using non-blocking sockets stuck in connect() for over 8 hours because of this...

00002630 <__xfrm_lookup>:
...
    290b:   b8 00 00 00 00          mov    $0x0,%eax
            290c: R_386_32  km_waitq
    2910:   e8 fc ff ff ff          call   2911 <__xfrm_lookup+0x2e1>
            2911: R_386_PC32    add_wait_queue
    2915:   a1 00 00 00 00          mov    0x0,%eax
            2916: R_386_32  per_cpu__current_task
    291a:   c7 00 01 00 00 00       movl   $0x1,(%eax)
    2920:   e8 fc ff ff ff          call   2921 <__xfrm_lookup+0x2f1>
            2921: R_386_PC32    schedule
    2925:   a1 00 00 00 00          mov    0x0,%eax
            2926: R_386_32  per_cpu__current_task
    292a:   c7 00 00 00 00 00       movl   $0x0,(%eax)
    2930:   b8 00 00 00 00          mov    $0x0,%eax
            2931: R_386_32  km_waitq
    2935:   89 da                   mov    %ebx,%edx
    2937:   e8 fc ff ff ff          call   2938 <__xfrm_lookup+0x308>
            2938: R_386_PC32    remove_wait_queue

-- 
Simon Arlott
