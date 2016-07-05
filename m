From: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Subject: Problem: BUG_ON hit in ppp_pernet() when re-connect after changing
 shared key on LAC
Date: Tue, 5 Jul 2016 02:50:54 +0000
Message-ID: <7fabf4defe2f468bbcc829247de956c0@svr-chch-ex1.atlnz.lc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "g.nault@alphalink.fr" <g.nault@alphalink.fr>
To: "linux-ppp@vger.kernel.org" <linux-ppp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am producing the attached bug trace when testing PPP connections. 
Specifically the steps I am doing are:

1. Configure PPP client and LAC with shared key and wait for client to 
negotiate an IP address.

2. Change the shared key on the LAC.

3. Bring the PPP client interface down and up to make it reconnect.

4. Repeat down/up until bug occurs.

Using printk I have confirmed that ppp_pernet() is called from 
ppp_connect_channel() when the BUG occurs (i.e. pch->chan_net is NULL).

This behavior appears to have been introduced in commit 1f461dc ("ppp: 
take reference on channels netns").

Thanks,
Matt

-------

Kernel bug detected[#1]:
CPU: 0 PID: 1796 Comm: pppd Tainted: P           O    4.4.6-at1 #1
task: 800000004cf9a610 ti: 80000000009b8000 task.ti: 80000000009b8000
$ 0   : 0000000000000000 0000000000000001 0000000000000000 0000000000000001
$ 4   : 8000000005174560 8000000005174560 8000000005175b30 00000000048d0550
$ 8   : 0000000004830000 0000000000000000 0000000000005fd8 0000000004900000
$12   : ffffffff80000000 8000000004900000 0000000000000014 0000000000000000
$16   : 0000000000000001 80000000008ec480 0000000010069dc4 fffffffffffffff2
$20   : 8000000004840000 80000000008ec4f8 000000001008e708 0000000010010000
$24   : 0000000004900000 0000000004900000
$28   : 80000000009b8000 80000000009bbd00 800000004c777d80 800000000438ade8
Hi    : 0000000000000000
Lo    : 09cd1da35f400000
epc   : 800000000438a5c8 ppp_ioctl+0x868/0x1098
ra    : 800000000438ade8 ppp_ioctl+0x1088/0x1098
Status: 10009ce3        KX SX UX KERNEL EXL IE
Cause : 00800034 (ExcCode 0d)
PrId  : 000d9602 (Cavium Octeon III)
Modules linked in: jitterentropy_rng echainiv drbg linux_user_bde(PO) 
linux_kernel_bde(PO) platform_driver(O) ipifwd(PO
)
Process pppd (pid: 1796, threadinfo=80000000009b8000, 
task=800000004cf9a610, tls=000000ffee40b700)
Stack : 0000000000000001 800000004cf9aa00 800000000480f1f8 80000000048d4600
           ffffffff80000000 8000000005188600 0000000010020000 
8000000004086dc0
           0000000010069dc4 800000004c777d80 800000004f90bba8 
000000000000000b
           0000000010069dc4 ffffffff8004743a 000000001008e708 
0000000010010000
           0000000010020000 800000000414e318 0000000000000001 
800000004cf9a610
           8000000005188600 8000000001440190 800000000480df00 
80000000015126a0
           80000000015126a0 80000000046792ac 80000000010ef080 
0000000000000004
           800000004c777d80 800000004c777d80 0000000010070000 
800000004c777d80
           000000000000000b 800000000414e930 0000000000000011 
0000000010044438
           000000000000000b ffffffffffffffff 000000001003eb80 
000000001003ec10
           ...
Call Trace:
[<800000000438a5c8>] ppp_ioctl+0x868/0x1098
[<800000000414e318>] do_vfs_ioctl+0x98/0x620
[<800000000414e930>] SyS_ioctl+0x90/0xd0
[<8000000004035e80>] syscall_common+0x44/0x68


Code: de2200a0  10400202  0000182d <00030336> 3c038000  3c080481 
dc421420  64630000  0003183c
---[ end trace 72203e44575f38a6 ]---
