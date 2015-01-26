From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: Re: [PATCH] net/9p: fix format string in p9_mount_tag_show()
Date: Mon, 26 Jan 2015 20:28:20 +0300
Message-ID: <54C67934.2000807@samsung.com>
References: <1422290896-25042-1-git-send-email-a.ryabinin@samsung.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD302F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	"v9fs-developer@lists.sourceforge.net"
	<v9fs-developer@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <063D6719AE5E284EB5DD2968C1650D6D1CAD302F@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/26/2015 08:04 PM, David Laight wrote:
> From: Andrey Ryabinin
>> Using "%s" for non-NULL terminated string is quite
>> dangerous, since this causes reading out of bounds.
>> chan->tag is non-NULL terminated, so precision
>> must be specified for printing it.
>>
>> Fixes: 86c8437383ac ("net/9p: Add sysfs mount_tag file for virtio 9P device")
>> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
>> ---
>>  net/9p/trans_virtio.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
>> index daa749c..f0d5f90 100644
>> --- a/net/9p/trans_virtio.c
>> +++ b/net/9p/trans_virtio.c
>> @@ -504,7 +504,8 @@ static ssize_t p9_mount_tag_show(struct device *dev,
>>  	vdev = dev_to_virtio(dev);
>>  	chan = vdev->priv;
>>
>> -	return snprintf(buf, chan->tag_len + 1, "%s", chan->tag);
> 
> Note the 'buffer length' passed to snprintf().

Yes, but 'buffer length' is length of buf, not chan->tag.
The problem with "%s" is that vsnprintf expects to chan->tag to be NULL-terminated,
so it calls strnlen(chan->tag, -1).
Thus we read beyond of allocated memory range:

==================================================================
BUG: AddressSanitizer: out of bounds access in strnlen+0xa7/0xb0 at addr ffff88006b882d79
Read of size 1 by task cat/669
=============================================================================
BUG kmalloc-16 (Not tainted): kasan: bad access detected
-----------------------------------------------------------------------------

Disabling lock debugging due to kernel taint
INFO: Allocated in p9_virtio_probe+0x523/0x11d0 age=7711 cpu=1 pid=1
        __slab_alloc.constprop.16+0x765/0x1220
        __kmalloc+0x380/0x630
        p9_virtio_probe+0x523/0x11d0
        virtio_dev_probe+0x739/0x11e0
        really_probe+0x204/0xd10
        __driver_attach+0x2c1/0x470
        bus_for_each_dev+0x16c/0x280
        driver_attach+0x48/0x80
        bus_add_driver+0x490/0x970
        driver_register+0x274/0x620
        register_virtio_driver+0x97/0x140
        p9_virtio_init+0x31/0x33
        do_one_initcall+0x1fb/0x3a0
        kernel_init_freeable+0x40d/0x4b1
        kernel_init+0xe/0xf0
        ret_from_fork+0x7c/0xb0
INFO: Slab 0xffffea0001ae2080 objects=23 used=23 fp=0x          (null) flags=0x4000000000004080
INFO: Object 0xffff88006b882d70 @offset=3440 fp=0xffff88006b882ec8

Bytes b4 ffff88006b882d60: 00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a  ........ZZZZZZZZ
Object ffff88006b882d70: 2f 64 65 76 2f 72 6f 6f 74 6b 6b 6b 6b 6b 6b a5  /dev/rootkkkkkk.
Redzone ffff88006b882d80: cc cc cc cc cc cc cc cc                          ........
Padding ffff88006b882ec0: 5a 5a 5a 5a 5a 5a 5a 5a                          ZZZZZZZZ
CPU: 3 PID: 669 Comm: cat Tainted: G    B          3.19.0-rc5+ #168
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
 ffff88006b882d70 ffff880069b8f6e8 ffffffff82101090 0000000000000053
 ffff88006c807a80 ffff880069b8f748 ffffffff8152b231 ffff880069b8f758
 ffff880069b8f708 ffff880069b8f738 ffff88006d19dd60 ffffffff8237bac4
Call Trace:
 [<ffffffff82101090>] dump_stack+0x45/0x57
 [<ffffffff8152b231>] print_trailer+0x221/0x4b0
 [<ffffffff8153b30a>] object_err+0x3a/0x50
 [<ffffffff8153fee2>] kasan_report_error+0x3a2/0x9c0
 [<ffffffff812ce570>] ? get_ksymbol+0x1b80/0x1b80
 [<ffffffff8153efb6>] ? kasan_unpoison_shadow+0x36/0x70
 [<ffffffff8153efb6>] ? kasan_unpoison_shadow+0x36/0x70
 [<ffffffff81540561>] __asan_report_load1_noabort+0x61/0x80
 [<ffffffff81878657>] ? strnlen+0xa7/0xb0
 [<ffffffff81878657>] strnlen+0xa7/0xb0
 [<ffffffff81197824>] ? __kernel_text_address+0x94/0xc0
 [<ffffffff8188197f>] string.isra.2+0x3f/0x2f0
 [<ffffffff81888dc2>] vsnprintf+0x392/0x23b0
 [<ffffffff814221f0>] ? __rmqueue+0x24c0/0x24c0
 [<ffffffff81888a30>] ? pointer.isra.17+0xd80/0xd80
 [<ffffffff8152b537>] ? check_bytes_and_report+0x77/0x290
 [<ffffffff81531d91>] ? deactivate_slab+0x4d1/0x1f00
 [<ffffffff820e1f00>] ? p9_virtio_close+0xd0/0xd0
 [<ffffffff8188af95>] snprintf+0x85/0xa0
 [<ffffffff8188af10>] ? vsprintf+0x20/0x20
 [<ffffffff81534970>] ? alloc_debug_processing+0x1e0/0x4a0
 [<ffffffff820e1fe8>] p9_mount_tag_show+0xe8/0x180
 [<ffffffff81b49295>] dev_attr_show+0x75/0x170
 [<ffffffff8153f20c>] ? memset+0x2c/0x40
 [<ffffffff817157de>] sysfs_kf_seq_show+0x3fe/0xe80
 [<ffffffff810144d0>] ? dump_trace+0x230/0x920
 [<ffffffff817153e0>] ? sysfs_remove_files+0xd0/0xd0
 [<ffffffff8153efb6>] ? kasan_unpoison_shadow+0x36/0x70
 [<ffffffff8153f063>] ? kasan_kmalloc+0x73/0x90
 [<ffffffff8170d849>] kernfs_seq_show+0x1b9/0x330
 [<ffffffff815ff75e>] seq_read+0x3be/0x1f30
 [<ffffffff814c3656>] ? handle_mm_fault+0xe86/0x2340
 [<ffffffff815ff3a0>] ? traverse+0x1000/0x1000
 [<ffffffff814cdeb1>] ? find_vma+0x21/0x210
 [<ffffffff810f582b>] ? __do_page_fault+0x2bb/0xea0
 [<ffffffff817109ae>] kernfs_fop_read+0x38e/0x6f0
 [<ffffffff810f5570>] ? mm_fault_error+0x410/0x410
 [<ffffffff81710620>] ? kernfs_vma_page_mkwrite+0x390/0x390
 [<ffffffff8156441b>] __vfs_read+0xbb/0x320
 [<ffffffff815647a3>] vfs_read+0x123/0x320
 [<ffffffff81564aa9>] SyS_read+0x109/0x270
 [<ffffffff815649a0>] ? vfs_read+0x320/0x320
 [<ffffffff810e9a39>] ? do_async_page_fault+0x19/0x80
 [<ffffffff82113be9>] system_call_fastpath+0x12/0x17
Memory state around the buggy address:
 ffff88006b882c00: fc fc fc 00 00 fc fc fc fc fc fc fc fc fc fc fc
 ffff88006b882c80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff88006b882d00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc 00 01
                                                                ^
 ffff88006b882d80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88006b882e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================




> 
>> +	return snprintf(buf, chan->tag_len + 1, "%.*s",
>> +			chan->tag_len, chan->tag);
> 
> Both these are equivalent to:
> 	buf[chan->tag_len]= 0;
> 	memcpy(buf, chan->tag, chan->tag_len);
> 
> using snprintf() is rather extreme.
> 

Indeed, memcpy is much better here.
