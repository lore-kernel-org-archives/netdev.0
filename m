From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: rwlock recursion on CPU#0, netfilter related?
Date: Sun, 25 Sep 2005 23:19:45 +0300
Message-ID: <20050925201945.GA21176@ee.oulu.fi>
References: <20050925105834.GA15243@ee.oulu.fi> <20050925134344.GJ731@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20050925134344.GJ731@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 25, 2005 at 03:43:44PM +0200, Harald Welte wrote:
> 1) how does your kernel .config look like?
http://cvs.fedora.redhat.com/viewcvs/devel/kernel/configs/config-generic?rev=1.60&view=auto
http://cvs.fedora.redhat.com/viewcvs/devel/kernel/configs/config-x86_64-generic?rev=1.16&view=auto

> 2) which modules are loaded
Module                  Size  Used by
w83627hf               46569  0 
eeprom                 17617  0 
i2c_sensor             12225  2 w83627hf,eeprom
i2c_isa                11329  0 
rfcomm                 61033  0 
l2cap                  46145  5 rfcomm
bluetooth              73317  4 rfcomm,l2cap
ipv6                  325889  16 
ppp_synctty            21057  0 
ppp_async              22465  1 
crc_ccitt              10817  1 ppp_async
ppp_generic            41953  6 ppp_synctty,ppp_async
slhc                   16193  1 ppp_generic
ip_conntrack_ftp       82177  0 
ipt_ULOG               18913  1 
ipt_state              10689  18 
ip_conntrack           60053  2 ip_conntrack_ftp,ipt_state
iptable_filter         11969  1 
ip_tables              32193  3 ipt_ULOG,ipt_state,iptable_filter
loop                   26449  0 
video                  27977  0 
button                 16481  0 
battery                19657  0 
ac                     14409  0 
ohci1394               46753  0 
ieee1394              381273  1 ohci1394
ohci_hcd               33249  0 
ehci_hcd               46157  0 
parport_pc             40621  0 
parport                52557  1 parport_pc
i2c_nforce2            16833  0 
i2c_core               34241  5 w83627hf,eeprom,i2c_sensor,i2c_isa,i2c_nforce2
shpchp                108009  0 
emu10k1_gp             12865  0 
gameport               27089  2 emu10k1_gp
snd_emu10k1           138629  0 
snd_rawmidi            39521  1 snd_emu10k1
snd_util_mem           14401  1 snd_emu10k1
snd_hwdep              20321  1 snd_emu10k1
snd_intel8x0           46273  0 
snd_ac97_codec        106757  2 snd_emu10k1,snd_intel8x0
snd_seq_dummy          12869  0 
snd_seq_oss            47012  0 
snd_seq_midi_event     17473  1 snd_seq_oss
snd_seq                74265  5 snd_seq_dummy,snd_seq_oss,snd_seq_midi_event
snd_seq_device         19281  5 snd_emu10k1,snd_rawmidi,snd_seq_dummy,snd_seq_oss,snd_seq
snd_pcm_oss            68465  0 
snd_mixer_oss          28225  1 snd_pcm_oss
snd_pcm               115401  4 snd_emu10k1,snd_intel8x0,snd_ac97_codec,snd_pcm_oss
snd_timer              37577  3 snd_emu10k1,snd_seq,snd_pcm
snd                    75681  12 snd_emu10k1,snd_rawmidi,snd_hwdep,snd_intel8x0,snd_ac97_codec,snd_seq_oss,snd_seq,snd_seq_device,snd_pcm_oss,snd_mixer_oss,snd_pcm,snd_timer
soundcore              19809  1 snd
snd_page_alloc         21713  3 snd_emu10k1,snd_intel8x0,snd_pcm
r8169                  43209  0 
forcedeth              30657  0 
floppy                 77865  0 
dm_snapshot            26369  0 
dm_zero                10817  0 
dm_mirror              32433  0 
ext3                  154577  3 
jbd                    76145  1 ext3
dm_mod                 73873  7 dm_snapshot,dm_zero,dm_mirror
sata_nv                19141  3 
libata                 61649  1 sata_nv
sd_mod                 29121  4 
scsi_mod              167801  2 libata,sd_mod

> 3) how does your ruleset look like?
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:RH-Firewall-1-INPUT - [0:0]
-A INPUT -j RH-Firewall-1-INPUT 
-A FORWARD -j RH-Firewall-1-INPUT 
-A RH-Firewall-1-INPUT -i lo -j ACCEPT 
-A RH-Firewall-1-INPUT -i eth1 -j ACCEPT 
-A RH-Firewall-1-INPUT -p icmp --icmp-type echo-request -j ACCEPT 
-A RH-Firewall-1-INPUT -p esp -j ACCEPT 
-A RH-Firewall-1-INPUT -p ah -j ACCEPT 
-A RH-Firewall-1-INPUT -p ipv6 -j ACCEPT 
-A RH-Firewall-1-INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
-A RH-Firewall-1-INPUT -j ULOG
-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport x -j ACCEPT
-A RH-Firewall-1-INPUT -p udp -m state --state NEW -m udp --dport y -j ACCEPT
(for a bunch of ports, some with -s sourcenet/24 etc.)
-A RH-Firewall-1-INPUT -j DROP
COMMIT
# Completed on Sun Sep 28 10:37:44 2003

So basically a single-host firewall with ULOG and ftp conntracking being the
only fancy things.

> 4) most importantly, have you enabled CONFIG_IP_NF_CONNTRACK_EVENTS ?
>    if yes, please disable, it's broken, a fix has been submitted, but I
>    don't know if it has propagated to Linus yet (netdev Message-ID:
>    <20050922143515.GD8917@rama.de.gnumonks.org>)
Enabled, so this could be it. But 2.6.14-rc2-git4 did crash too (although
it did take a bit longer for that to happen), and the changelog does state:

commit 1dfbab59498d6f227c91988bab6c71af049a5333
tree 6b20409a232ebe8c37f16d06b3fbcde6bec8f328
parent a82b748930fce0dab22c64075c38c830ae116904
author Harald Welte <laforge@netfilter.org> Thu, 22 Sep 2005 23:46:57 -0700
committer David S. Miller <davem@davemloft.net> Thu, 22 Sep 2005 23:46:57
-0700

    [NETFILTER] Fix conntrack event cache deadlock/oops

Which is this patch, right? Will verify whether disabling the option makes any
difference tomorrow, as well as your other recommendations.

> Also, I have that Ping time problem on my x86_64 debian unstable (smp).
> But only in 1 out of ten cases on average (when starting ping, ctrl+c,
> pin, ctrl+c, ...).  I've always assumed it's some 64bit problem in
> "ping" itself.
Happens for all packets on the "broken" kernels, and works a-ok (few ms
latencies to the same box) on the 2.6.13-era ones that don't crash.
Could be a different bug, sure.
