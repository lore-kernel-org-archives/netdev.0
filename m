From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH 0/5] fixups for mpc8360 rev. 2.1 erratum #2 (RGMII Timing)
Date: Thu, 8 Nov 2007 13:11:35 -0600
Message-ID: <20071108131135.e16a2f9a.kim.phillips@freescale.com>
References: <20071105121530.5c38fbb7.kim.phillips@freescale.com>
	<20071108141611.GA5770@localhost.localdomain>
	<20071108121508.39a65c33.kim.phillips@freescale.com>
	<20071108183952.GA18117@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, paulus@samba.org,
	Li Yang <leoli@freescale.com>, jgarzik@pobox.com
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071108183952.GA18117@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Nov 2007 21:39:52 +0300
Anton Vorontsov <avorontsov@ru.mvista.com> wrote:

> On Thu, Nov 08, 2007 at 12:15:08PM -0600, Kim Phillips wrote:
> > On Thu, 8 Nov 2007 17:16:11 +0300
> > Anton Vorontsov <avorontsov@ru.mvista.com> wrote:
> > 
> > > On Mon, Nov 05, 2007 at 12:15:30PM -0600, Kim Phillips wrote:
> > > > Hello all,
> > > > 
> > > > the following patches fix RGMII timing for rev. 2.1 of the mpc8360,
> > > > according to erratum #2 (erratum text included below).  Basically the
> > > > most intrusive part is the addition of two new RGMII Internal Delay
> > > > modes; one for TX delay only, and the other for RX delay only (i.e, not
> > > > both at the same time).
> > > > 
> > > > Please review, and since this affects both netdev and powerpc trees,
> > > > one maintainer should ack them for the other to push upstream (i.e,
> > > > Kumar acks them, and Leo picks them up to go through netdev or the
> > > > other way around; either way is fine with me).  I'm hoping they're
> > > > trivial enough to go in 2.6.24.
> > > > 
> > > > Depending on how the review goes, a follow-on patch to u-boot will be
> > > > sent out that fixes up the phy-connection-type in the device tree (from
> > > > "rgmii-id" to "rgmii-rxid" iff on mpc8360rev2.1).
> > > 
> > > I've upgraded CPU to rev2.1, board rev0.3.
> > > 
> > thanks for testing this.  I tested these patches on a "pilot assy 0.3".
> 
> Same here.
> 
> > > Applied 5/5 patches onto paulus/powerpc.git at e403149c92a. Here is
> > > the results:
> > > 
> > > If I use -rxid, then geth not able to transmit anything.
> > > With -txid geth not able to receive anything.
> > > 
> > > With just -id everything works fine though...
> > > 
> > > 
> > > Maybe there should be another condition, in addition to cpu rev2.1?
> > > 
> > the errata simply states 'pilot boards', but we can probably modify
> > u-boot to look at the cpu rev and the board rev (BCSR 12).
> > 
> > My bcsr12 looks like:
> > 
> > =>  md.b f800000c 1
> > f800000c: 10    .
> > 
> > what is yours?
> 
> => md.b f800000c 1
> f800000c: 10    .
> 
> :-/
> 
> U-Boot 1.3.0-rc3-g281df457-dirty (Nov  6 2007 - 18:19:35) MPC83XX
> CPU:   e300c1, MPC8360E, Rev: 21 at 528 MHz, CSB:  264 MHz
> 
> root@b1:~# cat /proc/cpuinfo 
> processor       : 0
> cpu             : e300c1
> clock           : 528.000000MHz
> revision        : 3.1 (pvr 8083 0031)
> bogomips        : 131.58
> timebase        : 66000000
> platform        : MPC836x MDS
> 

check.  :/

> 
> +               /* handle mpc8360ea rev.2.1 erratum 2: RGMII Timing */
> +               svid = mfspr(SPRN_SVR);
> +               if (svid == 0x80480021) {
> 
> ^^ that branch executes on the board I'm testing.

right, but whether it does or not doesn't affect your failure outcome
either I'm assuming.

> > If it's something like 0x03, the u-boot patch will probably look like:
> > 
> > if ((bcsr[12] == 0x10) &&
> >     (immr->sysconf.spridr == SPR_8360_REV21 ||
> >      immr->sysconf.spridr == SPR_8360E_REV21))
> > 	/* if phy-connection-type is "rgmii-id", set it to "rgmii-rxid" */
> >         ...
> > 
> > but these linux patches would remain the same (the clk and data delay
> > settings for the UCC's are still valid; it's just the PHY config
> > that is triggering your problem from what I can tell).
> 
> Yup, most likely this is not UCC specific, but PHY. For some reason
> delays making harm here...

hmm..

Net:   UEC: PHY is Marvell 88E11x1 (1410cc2)

I have jumper JP1 set to 3.3V.

can you send me your:

=> md.b f8000000 15
f8000000: 04 04 00 c6 94 60 00 00 ac 2f 00 b8 10 3f 30 02    .....`.../...?0.
f8000010: 05 07 05 15 11    .....

and maybe try the following on top of these 5 patches (to specify rgmii
mode in the bcsr's):

diff --git a/arch/powerpc/platforms/83xx/mpc836x_mds.c b/arch/powerpc/platforms/83xx/mpc836x_mds.c
index 0a72260..753071e 100644
--- a/arch/powerpc/platforms/83xx/mpc836x_mds.c
+++ b/arch/powerpc/platforms/83xx/mpc836x_mds.c
@@ -98,6 +98,11 @@ static void __init mpc836x_mds_setup_arch(void)
 			!= NULL){
 		uint svid;
 
+		/* configure RGMII mode for both GETH ports */
+#define BCSR8_TSECXM_RGMII 0xf0
+		clrbits8(&bcsr_regs[8], BCSR8_TSECXM_RGMII);
+
+
 		/* Reset the Ethernet PHY */
 #define BCSR9_GETHRST 0x20
 		clrbits8(&bcsr_regs[9], BCSR9_GETHRST);

Thanks,

Kim
