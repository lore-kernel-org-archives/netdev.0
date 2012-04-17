From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 5/6] vhost_net: fix use after free of vq->ubufs
Date: Tue, 17 Apr 2012 11:19:42 +0800
Message-ID: <4F8CE14E.5080508@redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com> <20120416060825.14140.32069.stgit@intel-e5620-16-2.englab.nay.redhat.com> <20120416132841.GB13113@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120416132841.GB13113@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/16/2012 09:28 PM, Michael S. Tsirkin wrote:
> On Mon, Apr 16, 2012 at 02:08:25PM +0800, Jason Wang wrote:
>> When zerocopy socket is used, ubufs pointer were used in handle_tx()
>> without any validation. This would cause NULL pointer deference after
>> it has been freed in vhost_net_set_backend(). Fix this by check the
>> pointer before using it.
>>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>
> OK so it's NULL dereference and not user after free :)
> Also could you clarify how does this happen pls?
> Don't we always initialize ubufs when vhost_sock_zcopy is set?

The problem happens when we want to disable backend. At this time ubufs 
were assigned to NULL and it may be dereferenced by handle_tx():

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffffa0474c57>] handle_tx+0x267/0x5c0 [vhost_net]
PGD 4230b1067 PUD 42227a067 PMD 0
Oops: 0000 [#1] SMP
CPU 7
Modules linked in: vhost_net ip6table_filter ip6_tables ebtable_nat 
ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 
nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM 
iptable_mangle iptable_filter ip_tables nfsd lockd nfs_acl auth_rpcgss 
sunrpc exportfs cpufreq_ondemand acpi_cpufreq freq_table mperf bridge 
stp llc ipv6 tun kvm_intel kvm hp_wmi sparse_keymap rfkill coretemp 
crc32c_intel ghash_clmulni_intel microcode serio_raw pcspkr sg iTCO_wdt 
iTCO_vendor_support tg3 snd_hda_codec_realtek snd_hda_intel 
snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd 
soundcore snd_page_alloc i7core_edac edac_core ixgbe dca mdio ext4 
mbcache jbd2 sd_mod crc_t10dif sr_mod cdrom firewire_ohci firewire_core 
crc_itu_t aesni_intel cryptd aes_x86_64 aes_generic mptsas mptscsih 
mptbase scsi_transport_sas ahci libahci floppy nouveau ttm 
drm_kms_helper drm i2c_core mxm_wmi video wmi dm_mirror dm_region_hash 
dm_log dm_mod [last unloaded: vhost_net]

Pid: 3993, comm: vhost-3991 Not tainted 3.3.0+ #10 Hewlett-Packard HP 
Z800 Workstation/0AECh
RIP: 0010:[<ffffffffa0474c57>] [<ffffffffa0474c57>] 
handle_tx+0x267/0x5c0 [vhost_net]
RSP: 0018:ffff880220b41d90 EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff8804222242b0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00007f5f495e6002
RBP: ffff880220b41e60 R08: 0000000000000000 R09: 0000000000000002
R10: 000000007fffffff R11: ffff8802246b7340 R12: ffff8804222243d8
R13: ffff8804222283d8 R14: 0000000004e20000 R15: ffff880422a1f690
FS: 0000000000000000(0000) GS:ffff88042fc60000(0000) knlGS:0000000000000000
CS: 0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000424786000 CR4: 00000000000027e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process vhost-3991 (pid: 3993, threadinfo ffff880220b40000, task 
ffff880222606a70)
Stack:
0000000000000000 0000000000000000 ffff880422220000 ffff880220b41df0
0000000000000007 ffff880200000000 0000000000000000 ffff8804222242b8
0000000000000000 0000000000000000 01ff880220b41fd8 ffff880422220000
Call Trace:
[<ffffffffa0474fc5>] handle_tx_net+0x15/0x20 [vhost_net]
[<ffffffffa0472cf4>] vhost_worker+0xe4/0x180 [vhost_net]
[<ffffffffa0472c10>] ? vhost_attach_cgroups_work+0x30/0x30 [vhost_net]
[<ffffffffa0472c10>] ? vhost_attach_cgroups_work+0x30/0x30 [vhost_net]
[<ffffffff8107096e>] kthread+0x9e/0xb0
[<ffffffff81516364>] kernel_thread_helper+0x4/0x10
[<ffffffff810708d0>] ? kthread_freezable_should_stop+0x70/0x70
[<ffffffff81516360>] ? gs_change+0x13/0x13
Code: 00 00 48 89 50 08 48 63 93 20 42 00 00 48 89 50 10 48 89 45 b0 48 
c7 45 b8 08 00 00 00 48 8b 83 30 42 00 00 48 89 85 60 ff ff ff <8b> 00 
85 c0 0f 84 1c 03 00 00 48 8b 85 60 ff ff ff f0 ff 00 8b
RIP [<ffffffffa0474c57>] handle_tx+0x267/0x5c0 [vhost_net]
RSP <ffff880220b41d90>
CR2: 0000000000000000
>
>> ---
>>   drivers/vhost/net.c |    7 ++++++-
>>   1 files changed, 6 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index f0da2c3..29abd65 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -163,10 +163,15 @@ static void handle_tx(struct vhost_net *net)
>>   	mutex_lock(&vq->mutex);
>>   	vhost_disable_notify(&net->dev, vq);
>>
>> +	zcopy = vhost_sock_zcopy(sock);
>> +	if (zcopy&&  !vq->ubufs) {
>> +		mutex_unlock(&vq->mutex);
>> +		return;
>> +	}
>> +
>>   	if (wmem<  sock->sk->sk_sndbuf / 2)
>>   		tx_poll_stop(net);
>>   	hdr_size = vq->vhost_hlen;
>> -	zcopy = vhost_sock_zcopy(sock);
>>
>>   	for (;;) {
>>   		/* Release DMAs done buffers first */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
