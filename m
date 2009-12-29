From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Tue, 29 Dec 2009 14:54:03 +0100
Message-ID: <20091229145403.39f82773@pluto.restena.lu>
References: <20091229084929.54912c0c@pluto.restena.lu>
	<1262077540.12520.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Benjamin Li" <benli@broadcom.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751871AbZL2NyL@vger.kernel.org>
In-Reply-To: <1262077540.12520.4.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Dec 2009 01:05:40 "Benjamin Li" <benli@broadcom.com> wrote:
> Hi Bruno,
> 
> It looks like the the NULL dereference is happening at a0fc.
> 
> a0f8:       48 8b 42 70             mov 0x70(%rdx),%rax 
> a0fc:       0f b7 10                movzwl (%rax),%edx
> a0ff:       31 c0                   xor    %eax,%eax
> 
> The offset of 0x70 is the bp field in the bnx2_napi structure.  (Seen
> in the bnx2_napi structure dump below)  These lines are found in the
> routine, bnx2_get_hw_tx_cons() which look like they were inlined by
> the compiler.  More specifically it looks like the dereference of the
> hw_tx_cons_ptr failed.
> 
> cons = *bnapi->hw_tx_cons_ptr;
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=drivers/net/bnx2.c;h=06b901152d4487fa04164437cc179661b44657fe;hb=74fca6a42863ffacaf7ba6f1936a9f228950f657#l2761
> 
> To be sure this is the case, could you send the .config file you are
> using or if you could send me the bnx2 kernel module built with the
> CFLAG '-g', then we can definitely verify where in the code it is
> crashing.
> 
> Did you see anything suspicious in the system kernel logs?  If you
> could isolate the logs from when the machine booted to when it crash
> and send it to us it would be very helpful. 

It crashes every now and then (since netconsole is enabled it does not
survive 24 hours :( ) while or just after transmitting log messages with
netconsole, the messages being transmitted are logging that occurs with
netfilter 'LOG' target.

Sample output as seen by netconsole recipient (1 packet per line, IP
addresses masked):

[ 2115.949606] (reject)output: IN= OUT=eth0
SRC=***.**.*.** DST=**.***.**.***
LEN=60 TOS=0x00 PREC=0x00 TTL=64 ID=29589
DF
PROTO=TCP
SPT=58991 DPT=80
WINDOW=5840
RES=0x00
SYN
URGP=0

[ 2115.949704] (reject)output: IN= OUT=eth0
SRC=***.**.*.** DST=**.***.**.***
[ 2115.949729] BUG: unable to handle kernel NULL pointer dereference at (null)
[ 2115.949732] IP: [<ffffffffa00680fc>] bnx2_poll_work+0x2c/0x12d0 [bnx2]
[ 2115.949742] PGD 5b6f0067 PUD 59c04067 PMD 0
[ 2115.949744] Oops: 0000 [#1] SMP
[ 2115.949746] last sysfs file: /sys/kernel/uevent_seqnum
[ 2115.949749] CPU 3
[ 2115.949750] Modules linked in: dm_round_robin scsi_dh_rdac ipmi_devintf netconsole squashfs configfs zlib_inflate ext2 loop dm_multipath scsi_dh dm_mod sg sr_mod cdrom ata_piix h
pwdt qla2xxx ipmi_si ahci bnx2 ipmi_msghandler libata uhci_hcd ehci_hcd
[ 2115.949764] Pid: 7926, comm: php-cgi Not tainted 2.6.31.9-x86_64 #1 ProLiant DL360 G5
[ 2115.949766] RIP: 0010:[<ffffffffa00680fc>]  [<ffffffffa00680fc>] bnx2_poll_work+0x2c/0x12d0 [bnx2]

Looks like netpoll is triggering suicide on BNX2.

Any way to get the NULL-pointer non-fatal would help a lot! (any
sensible thing to do when bnapi->hw_tx_cons_ptr is NULL that would
allow the system to continue working without killing everything?)


Regards,
Bruno
