From: Willy Tarreau <willy@w.ods.org>
Subject: Fwd: [Bug 1754] New: IPsec crash when sending 1st encrypted packet in tunnel mode
Date: Sat, 27 Dec 2003 22:05:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031227210557.GD1323@alpha.home.local>
References: <6460000.1072543132@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mbligh@aracnet.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <6460000.1072543132@[10.10.2.4]>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi !

Found on LKML but not on netdev (perhaps Martin forgot to Cc). Might be of
interest to people here.

Cheers,
Willy

On Sat, Dec 27, 2003 at 08:38:52AM -0800, Martin J. Bligh wrote:
> http://bugme.osdl.org/show_bug.cgi?id=1754
> 
>            Summary: IPsec crash when sending 1st encrypted packet in tunnel
>                     mode
>     Kernel Version: 2.6.0
>             Status: NEW
>           Severity: high
>              Owner: acme@conectiva.com.br
>          Submitter: rakon@hck.sk
> 
> 
> Distribution:lfs v.5.0
> Hardware Environment: desknote iBuddie ()
> Software Environment: lfs v.5.0 + ipsec-tools-0.2.2 and others...
> 
> Problem Description:
> After creating tunnel between two hosts connected with crossed twisted pair
> cable, I got a kernel crash after successfull IPsec SA establishment
> (kernel-2.4.23 + Freeswan-2.04 with x509 patch <==> kernel-2.6.0 +
> ipsec-tools-0.2.2) when sending 1st encrypted packet (simple ping). I see this
> screen when crash occurs:
> 
> KERNEL: assertion (x->km.state == XFRM_STATE_DEAD) failed at
> net/xfrm/xfrm_state.c (193)
> ------------[ cut here ]------------
> kernel BUG at net/xfrm/xfrm_state.c:54!
> invalid operand: 0000 [#1]
> CPU:    0
> EIP:    0060:[<c0341626>]    Not tainted
> EFLAGS: 00010202
> EIP is at xfrm_state_gc_destroy+0x16/0xd0
> eax: 00000001   ebx: ca8c0000   ecx: cbc8c000   edx: ca8c0120
> esi: cbc8df6c   edi: c04b8f20   ebp: cbc8c000   esp: cbc8df60
> ds: 007b   es: 007b   ss:0068
> Process events/0 (pid: 3, threadinfo=cbc8c000 task=cbfa8c80)
> Stack: cbc8df6c c0341756 ca8c0000 ca8c0000 ca8c0000 cbfedc60 c04b8f24 c012b51b
>        00000000 cbfedc78 cbfedc70 00000000 c03416e0 cbfedc68 cbc8c000 cbfedc60
>        00000001 00000000 c0119e80 00010000 00000000 c03b6380 c11eff1c c010ab96
> Call Trace:
>  [<c0341756>] xfrm_state_gc_task+0x76/0x90
>  [<c012b51b>] worker_thread+0x1ab/0x2a0
>  [<c03416e0>] xfrm_state_gc_task+0x0/0x90
>  [<c0119e80>] default_wake_function+0x0/0x20
>  [<c010ab96>] ret_from_fork+0x6/0x20
>  [<c0119e80>] default_wake_function+0x0/0x20
>  [<c012b370>] worker_thread+0x0/0x2a0
>  [<c0108d65>] kernel_thread_helper+0x5/0x10
> 
> Code: 0f 0b 36 00 c1 ed 3a c0 8b 83 d0 00 00 00 85 c0 0f 85 94 00
> 
> Steps to reproduce:
> * I'll use xml tags (name of file) as start/end of file marks
> 
> 1) run this script:
> <policy>
> # ! /usr/sbin/setkey -f
> flush;
> spdflush;
> 
> spdadd 10.0.0.22/32 0.0.0.0/0 any
>        -P out ipsec esp/tunnel/10.0.0.1-10.0.0.22/require;
> spdadd 0.0.0.0/0 10.0.0.22/32 any
>        -P out ipsec esp/tunnel/10.0.0.1-10.0.0.22/require;
> </policy>
> 
> 2) run "racoon -F -f racoon.conf"
> where racoon.conf contains:
> 
> <racoon.conf>
> path certificate "/etc/ipsec.d";
> remote 10.0.0.1 {
>   exchange_mode main;
>   certificate_type x509 "mycert.pem" "mycert-key.pem"
>   verify_cert on;
>   my_identifier asn1dn;
>   peers_identifier asn1dn;
>   proposal {
>     encryption_algorithm 3des;
>     hash_algorithm md5;
>     authentication_method rsasig;
>     dh_group 2;
>   }
> }
> 
> sainfo anonymous {
>   pfs_group 2;
>   encryption_algorithm 3des;
>   authentication_algorithm hmac_md5;
>   compression_algorithm deflate;
> }
> </racoon.conf>
> 
> 3) run "ping 10.0.0.1" and see the crash screen
> 
> Reason of crash:
> 
> I've found the problem in policies script (see point 1), where is:
> 
> spdadd 10.0.0.2/32 0.0.0.0/0 any
>        -P out ipsec esp/tunnel/10.0.0.1-10.0.0.2/require;
> spdadd 0.0.0.0/0 10.0.0.2/32 any
>        -P out ipsec esp/tunnel/10.0.0.1-10.0.0.2/require;
> 
> instead of:
> 
> spdadd 10.0.0.2/32 0.0.0.0/0 any
>        -P out ipsec esp/tunnel/10.0.0.2-10.0.0.1/require;
> spdadd 0.0.0.0/0 10.0.0.2/32 any
>        -P out ipsec esp/tunnel/10.0.0.1-10.0.0.2/require;
> 
> Note the tunnel specification in the 10.0.0.2/32 -> 0.0.0.0/0 rule. When using
> this second form, kernel doesn't crash and everything (at least pings and ssh to
> peer) works as expected.
> I guess this is a problem of kernel, since kernel shouldn't crash under any
> circumstances. But this could be a problem of ipsec-tools-0.2.2 as well since it
> allows incorrect input from user - however, the latter doesn't have to be true
> under certain conditions.
> 
> Regards.
> 
> PS: If more feedback is needed, send me an email.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
