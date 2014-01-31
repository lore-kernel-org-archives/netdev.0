From: Richard Yao <ryao@gentoo.org>
Subject: Re: [PATCH] 9p/trans_virtio.c: Fix broken zero-copy on vmalloc() buffers
Date: Thu, 30 Jan 2014 20:02:23 -0500
Message-ID: <1EB31694-2C49-415B-8394-A91724665D71@gentoo.org>
References: <1391104968-10258-1-git-send-email-ryao@gentoo.org> <1391104968-10258-2-git-send-email-ryao@gentoo.org> <20140130.162926.561686911250624301.davem@davemloft.net> <20140130.164451.873520736572570393.davem@davemloft.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "ericvh@gmail.com" <ericvh@gmail.com>,
	"rminnich@sandia.gov" <rminnich@sandia.gov>,
	"lucho@ionkov.net" <lucho@ionkov.net>,
	"v9fs-developer@lists.sourceforge.net"
	<v9fs-developer@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel@gentoo.org" <kernel@gentoo.org>,
	"aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"cov@codeaurora.org" <cov@codeaurora.org>,
	"behlendorf1@llnl.gov" <behlendorf1@llnl.gov>,
	"mthode@mthode.org" <mthode@mthode.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140130.164451.873520736572570393.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jan 30, 2014, at 7:44 PM, David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Thu, 30 Jan 2014 16:29:26 -0800 (PST)
> 
>> From: Richard Yao <ryao@gentoo.org>
>> Date: Thu, 30 Jan 2014 13:02:48 -0500
>> 
>>> The 9p-virtio transport does zero copy on things larger than 1024 bytes
>>> in size. It accomplishes this by returning the physical addresses of
>>> pages to the virtio-pci device. At present, the translation is usually a
>>> bit shift.
>>> 
>>> However, that approach produces an invalid page address when we
>>> read/write to vmalloc buffers, such as those used for Linux kernle
>>> modules. This causes QEMU to die printing:
>>> 
>>> qemu-system-x86_64: virtio: trying to map MMIO memory
>>> 
>>> This patch enables 9p-virtio to correctly handle this case. This not
>>> only enables us to load Linux kernel modules off virtfs, but also
>>> enables ZFS file-based vdevs on virtfs to be used without killing QEMU.
>>> 
>>> Also, special thanks to both Avi Kivity and Alexander Graf for their
>>> interpretation of QEMU backtraces. Without their guidence, tracking down
>>> this bug would have taken much longer.
>>> 
>>> Signed-off-by: Richard Yao <ryao@gentoo.org>
>>> Acked-by: Alexander Graf <agraf@suse.de>
>>> Reviewed-by: Will Deacon <will.deacon@arm.com>
>> 
>> Applied, thanks.
> 
> Actually I had to revert, is_vmalloc_or_malloc_addr() is not exported to
> modules, so this change breaks the build.

Thanks for catching that. I had originally used is_vmalloc_addr() instead of is_vmalloc_or_malloc_addr(), but changed it after realizing this did not correct the problem on all architectures. The is_vmalloc_addr() lives in headers. I will send out a patch to get that symbol exported and resubmit this after it is merged.