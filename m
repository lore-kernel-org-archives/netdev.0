From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 0/2] net: Replace custom page based bitmap with IDA
Date: Sun, 12 Feb 2017 13:57:32 +1100
Message-ID: <1486868254-5386-1-git-send-email-me@tobin.cc>
Cc: mawilcox@microsoft.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Tobin C. Harding" <me@tobin.cc>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current implementation of __dev_alloc_name uses a custom bitmap of
a single page to iterate network device id's and allocate an
unused id. This is seemingly the same task that the IDA does. Also the
current implementation leads to a upper limit of 8 * PAGE_SIZE on the
number of network id's (for each name format i.e eth0).

This patch uses the kernel's IDA as a replacement to the page based
bitmap. This has the effect of simplifying the code and removing
the upper limit.

Testing was carried out using a simple network device module, the
core of which is;

#define NDEVICES 32768     /* current implementation hard limit */

/* test driver */
static int tm_init_module(void)
{
	int result;
	int i;
	unsigned long before, after, diff, msec;

	pr_debug("tm: init module");

	before = jiffies;

	for (i = 0; i < NDEVICES; i++) {

		devs[i] = alloc_netdev(0, "sn%d",
				NET_NAME_UNKNOWN, tm_init);

		if (!devs[i])
			return -ENOMEM;

		result = register_netdev(devs[i]);
		if (result) {
			pr_err("tm: error %i registering device \"%s\"\n",
				result, devs[i]->name);
			tm_cleanup();
			return -ENODEV;
		}
	}

	after = jiffies;
	diff = (long)after - (long)before;
	msec = diff * 1000 / HZ;
	pr_debug("tm: Total milliseconds: %ld\n", msec);

	return 0;
}
module_init(tm_init_module);

The main objective of this patch is to simplify the code of __dev_alloc_name.
As a side effect the hard limit is also removed. Results from running the,
admittedly convoluted, test module show that the patched version is slightly slower.


Benchmarks
==========

System: core i5 Linux 4.10.0-rc7+ #18 SMP

$ qemu-system-x86_64 -kernel arch/x86_64/boot/bzImage -drive file=/home/tobin/build/imgs/qemu-image.img,index=0,media=disk,format=raw -append "root=/dev/sda console=ttyS0" --enable-kvm --nographic -m 12G


Current implementation

#define NDEVICES 30000

[  134.376741] tm: Total milliseconds: 127152

Patched version

#define NDEVICES 30000

[  226.960212] tm: Total milliseconds: 220756

#define NDEVICES 35000

[  276.590994] tm: Total milliseconds: 270620


Tobin C. Harding (2):
  include: Fix checkpatch whitespace error and warning
  net: Replace custom page based bitmap with IDA

 include/linux/idr.h |  4 ++--
 net/core/dev.c      | 20 ++++++--------------
 2 files changed, 8 insertions(+), 16 deletions(-)

-- 
2.7.4
