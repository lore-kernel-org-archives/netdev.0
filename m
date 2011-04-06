From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/34] Make kernel build deterministic
Date: Wed, 6 Apr 2011 11:01:19 +0200
Message-ID: <20110406090119.GB16597@elte.hu>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: anil_ravindranath@pmc-sierra.com, mchehab@redhat.com,
	benh@kernel.crashing.org, x86@kernel.org, mac@melware.de,
	aacraid@adaptec.com, linux-mtd@lists.infradead.org,
	allan.stephens@windriver.com, hpa@zytor.com,
	netdev@vger.kernel.org, t.sailer@alumni.ethz.ch,
	gwingerde@gmail.com, IvDoorn@gmail.com, elf@buici.com,
	cluster-devel@redhat.com, ccaulfie@redhat.com, mingo@redhat.com,
	dougthompson@xmission.com, linux-usb@vger.kernel.org,
	linux-media@vger.kernel.org, arnaud.giersch@free.fr,
	linux-kbuild@vger.kernel.org, teigland@redhat.com,
	tony.olech@elandigitalsystems.com, apw@canonical.com,
	linux-hams@vger.kernel.org, tglx@linutronix.de,
	swhiteho@redhat.com, linux-arm-kernel@lists.infradead.org,
	linux-edac@vger.kernel.org, jon.maloy@ericsson.com,
	linux-scsi@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	gregkh@suse.de, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


* Michal Marek <mmarek@suse.cz> wrote:

> 
> Hi,
> 
> this series makes it possible to build bit-identical kernel image and
> modules from identical sources. Of course the build is already
> deterministic in terms of behavior of the code, but the various
> timestamps embedded in the object files make it hard to compare two
> builds, for instance to verify that a makefile cleanup didn't
> accidentally change something. A prime example is /proc/config.gz, which
> has both a timestamp in the gzip header and a timestamp in the payload
> data. With this series applied, a script like this will produce
> identical kernels each time:
> 
> #!/bin/bash
> rm -rf /dev/shm/{source,build}{,1,2}
> export KCONFIG_NOTIMESTAMP=1
> export KBUILD_BUILD_TIMESTAMP='Sun May  1 12:00:00 CEST 2011'
> export KBUILD_BUILD_USER=user
> export KBUILD_BUILD_HOST=host
> export ROOT_DEV=FLOPPY
> for i in 1 2; do
> 	mkdir /dev/shm/source
> 	# randomize the inode order just for fun
> 	git ls-tree -r -z --name-only HEAD | sort -R -z | xargs -0 \
> 		cp --parents --target=/dev/shm/source
> 	pushd /dev/shm/source
> 	mkdir /dev/shm/build
> 	>/dev/shm/build/all.config
> 	for opt in GCOV_KERNEL UBIFS_FS_DEBUG; do
> 		echo "# CONFIG_$opt is not set" >>"/dev/shm/build"/all.config
> 	done
> 	make O="/dev/shm/build" KCONFIG_ALLCONFIG=1 allmodconfig
> 	make O="/dev/shm/build" -j64
> 	popd
> 	mv /dev/shm/source /dev/shm/source$i
> 	mv /dev/shm/build /dev/shm/build$i
> done
> diff -rq /dev/shm/build{1,2}

Nice!

Acked-by: Ingo Molnar <mingo@elte.hu>

> Unfortunatelly, this cannot be used to validate indentation-only
> patches, even if CONFIG_DEBUG_INFO is turned off. This is because of the
> __FILE__ and __LINE__ macros used in many places. For the same reason,
> the source and build directory needs to be the same, otherwise the
> results will differ.

Nor can it be used to validate untrusted patches in general: a subtle change 
might be introduced in a piece of code that is dependent on a .config detail 
that is off for that particular build.

But in the common case it's nice to be able to have deterministic/reproducable 
builds.

Thanks,

	Ingo
