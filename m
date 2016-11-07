From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [lkp] [net]  af1fee9821:
 BUG:spinlock_trylock_failure_on_UP_on_CPU
Date: Mon, 7 Nov 2016 18:34:50 +0100
Message-ID: <20161107173450.GC3118@lunn.ch>
References: <20161107022628.GA21529@yexl-desktop>
 <20161107093148.GA27001@lunn.ch>
 <20161107132714.GA10669@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel test robot <xiaolong.ye@intel.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        "David S. Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        lkp@01.org
To: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161107132714.GA10669@microsemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 07, 2016 at 02:27:14PM +0100, Allan W. Nielsen wrote:
> Hi,
> 
> I tried to get this "lkp" up and running, but I had some troubles gettting
> these scripts to work.
> 
> But it seems like it can be reproduced using th eprovided config file, and qemu.
> 
> Here is what I did:
> 
> # reproduce original bug
> git reset --hard af1fee98219992ba2c12441a447719652ed7e983
> mkdir bug-build
> cp config-4.8.0-14895-gaf1fee9 bug-build/.config
> make O=bug-build oldconfig
> make O=bug-build -j8
> qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G -kernel \
>     ../net-next/bug-build/arch/x86_64/boot/bzImage -nographic
> <see-output-1-below>
> # bug seemed to be re-produced
> 
> 
> # Try previous version
> git reset --hard 32ab0a38f0bd554cc45203ff4fdb6b0fdea6f025
> make O=bug-build oldconfig
> make O=bug-build -j8
> qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G -kernel \
>     ../net-next/bug-build/arch/x86_64/boot/bzImage -nographic
> <see-output-2-below>
> # bug seemed to disappear
> 
> 
> # Try the buggy revision again - but without MICROSEMI_PHY
> git reset --hard af1fee98219992ba2c12441a447719652ed7e983
> sed -e "/MICROSEMI_PHY/d" -i bug-build/.config
> make O=bug-build oldconfig
> cat bug-build/.config | grep MICROSEMI_PHY
> qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G -kernel \
>     ../net-next/bug-build/arch/x86_64/boot/bzImage -nographic
> <see-output-3-below>
> # bug still seem to be there...
> 
> 
> Not sure what this tells me, any hints are more than welcome.

If the bug happens without your code being compiled, it cannot be your
code. It suggests the patch is moving code around in such a way to
trigger the issue, but it is not the source of the issue itself. To me
it seems like memory corruption or uninitialised variables in some
other code, or maybe DMA from the stack, which was never allowed but
mostly work on some platforms, but the recent change to virtual mapped
stacks as broken.

Your code is off the hook, thanks for the testing you did.

     Andrew
