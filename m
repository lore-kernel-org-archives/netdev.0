From: "John Stoffel" <john@stoffel.org>
Subject: Re: 4.4-rc3, KVM, br0 and instant hang
Date: Sat, 5 Dec 2015 12:31:16 -0500
Message-ID: <22115.8036.357755.548697@quad.stoffel.home>
References: <22114.26609.457727.203801@quad.stoffel.home>
	<20151205162328.GA32532@quad.stoffel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, axboe@fb.com, jaxboe@fusionio.com
To: John Stoffel <john@quad.stoffel.home>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151205162328.GA32532@quad.stoffel.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "John" == John Stoffel <john@quad.stoffel.home> writes:

John> On Fri, Dec 04, 2015 at 11:28:33PM -0500, John Stoffel wrote:
>> 
>> Hi all,

>> Anyway, if I try to boot up anything past the 4.2.6 kernel, the system
>> locks up pretty quickly with an oops message that scrolls off the
>> screen too far.  I've got some pictures which I'll attach in a bit,
>> maybe they'll help.  So at first I thought it was something to do with
>> bad kworker threads, or SCSI or SATA interactions, but as I tried to
>> configure Netconsole to log to my beaglebone black SBC, I found out
>> that if I compiled and installed 4.4-rc3, started the bridge up (br0),
>> even started KVM, but did NOT start my VMs, the system was stable.

I've now figured out that I can disable all my VMs from autostart, and
the system will come up properly.  Then I can setup netconsole to use
the br0 interface, do an  "echo t > sysrq" to confirm it's working,
and start up the VMs.

On my most recent bootup, I thought it was ok, since the VMs worked
for a while (10 minutes) and I was starting to re-compile the kernel
again to make more modules compiled in.  No luck, I got the following
crash dump (partial) on my netconsole box.

[ 1434.266524] ------------[ cut here ]------------
[ 1434.266643] WARNING: CPU: 2 PID: 179 at block/blk-merge.c:435 blk_rq_map_sg+0x2d9/0x2eb()
[ 1434.266739] Modules linked in: vhost_net vhost macvtap macvlan tun binfmt_misc cpufreq_stats cpuf
req_powersave cpufreq_conservative cpufreq_userspace loop snd_pcm_oss snd_mixer_oss snd_pcm snd_time
r snd soundcore pcspkr serio_raw edac_mce_amd k10temp edac_core sp5100_tco i2c_piix4 asus_atk0110 wm
i shpchp evdev acpi_cpufreq netconsole configfs dm_mod raid1 usbhid md_mod
[ 1434.267691] CPU: 2 PID: 179 Comm: kworker/2:1H Not tainted 4.4.0-rc3 #3
[ 1434.267754] Hardware name: System manufacturer System Product Name/M4A88TD-V EVO/USB3, BIOS 1401
   06/11/2010
   [ 1434.267851] Workqueue: kblockd cfq_kick_queue
   [ 1434.267927]  0000000000000000 ffff88040ba57b78 ffffffff812ded80 0000000000000000
   [ 1434.268103]  ffff88040ba57bb0 ffffffff81071184 ffffffff812c4cba ffff88034aecee60
   [ 1434.268270]  0000000000000000 0000000000000002 ffff88040bd4b7c8 ffff88040ba57bc0
   [ 1434.268440] Call Trace:
   [ 1434.268501]  [<ffffffff812ded80>] dump_stack+0x44/0x55
   [ 1434.268565]  [<ffffffff81071184>] warn_slowpath_common+0x95/0xae
   [ 1434.268628]  [<ffffffff812c4cba>] ? blk_rq_map_sg+0x2d9/0x2eb
   [ 1434.268688]  [<ffffffff81071241>] warn_slowpath_null+0x15/0x17
   [ 1434.268749]  [<ffffffff812c4cba>] blk_rq_map_sg+0x2d9/0x2eb
   [ 1434.268814]  [<ffffffff814fe816>] scsi_init_sgtable+0x3f/0x63
   [ 1434.268876]  [<ffffffff814fec2a>] scsi_init_io+0x47/0x1ab
   [ 1434.268937]  [<ffffffff81535109>] sd_init_command+0x3e5/0xba6
   [ 1434.268997]  [<ffffffff814f91d9>] ? scsi_host_alloc_command+0x48/0xb0
   [ 1434.269060]  [<ffffffff814fee14>] scsi_setup_cmnd+0x86/0x109
   [ 1434.269123]  [<ffffffff814fef3e>] scsi_prep_fn+0xa7/0x139
   [ 1434.269185]  [<ffffffff812c0ddd>] blk_peek_request+0x169/0x1de
   [ 1434.269246]  [<ffffffff81500269>] scsi_request_fn+0x26/0x2a2
   [ 1434.269308]  [<ffffffff8102f9c4>] ? __switch_to+0x1e9/0x3f1
   [ 1434.269372]  [<ffffffff812bde39>] __blk_run_queue_uncond+0x22/0x2b
   [ 1434.269433]  [<ffffffff812bde56>] __blk_run_queue+0x14/0x16
   [ 1434.269494]  [<ffffffff812d950f>] cfq_kick_queue+0x2a/0x3a
   [ 1434.269554]  [<ffffffff81082a4e>] process_one_work+0x144/0x217
   [ 1434.269618]  [<ffffffff81082f9e>] worker_thread+0x1e3/0x28c
   [ 1434.269678]  [<ffffffff81082dbb>] ? rescuer_thread+0x270/0x270
   [ 1434.269738]  [<ffffffff81082dbb>] ? rescuer_thread+0x270/0x270
   [ 1434.269800]  [<ffffffff81086a75>] kthread+0xb2/0xba
   [ 1434.269864]  [<ffffffff810869c3>] ? kthread_parkme+0x1f/0x1f
   [ 1434.269925]  [<ffffffff816efc5f>] ret_from_fork+0x3f/0x70


And it stops and the system locks hard, it won't respond to
magic-sysrq at all and I have to hit the reset button.  Is there
anything I can provide for more details, or config options I can add
to do better debugging?

So now I'm doing yet another re-compile, but I'm making deadline be my
default scheduler.  My system is pretty simple in setup, it's mostly
triple mirrored RAID1 devices:

    quad:/sys/devices# cat /proc/mdstat
    Personalities : [raid1]
    md2 : active raid1 sdg1[0] sdc1[3] sde1[1]
	  976628736 blocks super 1.2 [3/3] [UUU]
		bitmap: 0/8 pages [0KB], 65536KB chunk

    md4 : active raid1 sdf1[3] sdd1[1] sda1[2]
	  1953380736 blocks super 1.2 [3/3] [UUU]
		bitmap: 0/15 pages [0KB], 65536KB chunk

    md0 : active raid1 sdh2[0] sdj2[3] sdi2[4]
	  185545656 blocks super 1.2 [3/3] [UUU]
		bitmap: 1/2 pages [4KB], 65536KB chunk

    unused devices: <none>


And once this new kernel is compiled and installed, I'll also change
my disks to deadline scheduler and fire up the VMs to see what
happens.
