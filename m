From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Sat, 29 Jun 2013 00:20:28 -0700
Message-ID: <1372490428.3301.300.camel@edumazet-glaptop>
References: <51CBAA48.3080802@oracle.com>
	  <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com>
	  <1372402340.3301.229.camel@edumazet-glaptop>
	 <1372412262.3301.251.camel@edumazet-glaptop> <51CE1E19.3020108@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zheng.x.li@oracle.com" <zheng.x.li@oracle.com>,
	Xen Devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51CE1E19.3020108@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-06-29 at 07:36 +0800, Joe Jin wrote:
> Hi Eric,
> 
> The patch not fix the issue and panic as same as early I posted:
> > BUG: unable to handle kernel paging request at ffff88006d9e8d48
> > IP: [<ffffffff812605bb>] memcpy+0xb/0x120
> > PGD 1798067 PUD 1fd2067 PMD 213f067 PTE 0
> > Oops: 0000 [#1] SMP 
> > CPU 7 
> > Modules linked in: dm_nfs tun nfs fscache auth_rpcgss nfs_acl xen_blkback xen_netback xen_gntdev xen_evtchn lockd sunrpc bridge stp llc bonding be2iscsi iscsi_boot_sysfs ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp bnx2i cnic uio ipv6 cxgb3i libcxgbi cxgb3 mdio dm_round_robin dm_multipath libiscsi_tcp libiscsi scsi_transport_iscsi xenfs xen_privcmd video sbs sbshc acpi_memhotplug acpi_ipmi ipmi_msghandler parport_pc lp parport ixgbe dca sr_mod cdrom bnx2 radeon ttm drm_kms_helper drm snd_seq_dummy i2c_algo_bit i2c_core snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss serio_raw snd_pcm snd_timer snd soundcore snd_page_alloc iTCO_wdt pcspkr iTCO_vendor_support pata_acpi dcdbas i5k_amb ata_generic hwmon floppy ghes i5000_edac edac_core 
 hed dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod usb_storage lpfc scsi_transport_fc scsi_tgt ata_piix sg shpchp mptsas mptscsih mptbase scsi_transport_sas sd_mod crc_t10dif ext3!
>   jbd mbcac
> he
> >
> >
> > Pid: 0, comm: swapper Tainted: G        W   2.6.39-300.32.1.el5uek #1 Dell Inc. PowerEdge 2950/0DP246


By the way my patch was for current kernels, not for 2.6.39

For instance, I was not able to reproduce the crash with 3.3

RCU in neighbour code was added in 2.6.37, but it looks like this code
is a bit fragile because all the kfree_skb() are done while neighbour
locks are held.

So if a skb destructor triggers a new call to neighbour code, I presume
some bad things can happen. LOCKDEP could eventually help to detect
this.

You could try to replace these kfree_skb() calls to dev_kfree_skb_irq()
just in case.

(Do not forget the __skb_queue_purge() ones)

Try a LOCKDEP build as well.
