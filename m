From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: RE: [PATCH v2] ibm_newemac: Add support for GPCS, SGMIIandM88E1112 PHY
Date: Thu, 02 Oct 2008 23:48:24 +1000
Message-ID: <1222955304.12264.114.camel@pasglop>
References: <1222929477-10329-1-git-send-email-vgallardo@amcc.com>
	<1222929920.12264.96.camel@pasglop>
	<0CA0A16855646F4FA96D25A158E299D602C81377@SDCEXCHANGE01.ad.amcc.com>
	<1222932759.12264.104.camel@pasglop>
	<20081002063320.7b2331b4@zod.rchland.ibm.com>
	<1222943668.12264.106.camel@pasglop>
	<20081002065648.285cce25@zod.rchland.ibm.com>
	<20081002115507.GB2227@yoda.jdub.homelinux.org>
	<1222951068.12264.109.camel@pasglop>
	<0CA0A16855646F4FA96D25A158E299D602C8137C@SDCEXCHANGE01.ad.amcc.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Victor Gallardo <vgallardo@amcc.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <0CA0A16855646F4FA96D25A158E299D602C8137C@SDCEXCHANGE01.ad.amcc.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-10-02 at 06:40 -0700, Victor Gallardo wrote:
> > Victor, while at it, can you do a fixup patch on top of it that guards
> > the new feature with a Kconfig option like some of the other ones so
> > that the code for it doesn't get compiled in when building, for example.
> > for 405GP only ?
> >
> > The trick is to have the option not be part of the possible mask, so
> > that the compiler optimises out the feature tests as if (0) (gcc
> > nowadays is supposedly smart enough to rip off the code when it finds
> > such constructs).
> 
> Hi Ben, 
>  
> Can you give an example of what you are asking for? I am not sure if I understand your request.

Well, if you look at the way emac_has_feature is implemented:

static inline int emac_has_feature(struct emac_instance *dev,
				   unsigned long feature)
{
	return (EMAC_FTRS_ALWAYS & feature) ||
	       (EMAC_FTRS_POSSIBLE & dev->features & feature);
}

And now, if you look a few lines up, you see that various CONFIG_*
options define what is in EMAC_FTRS_POSSIBLE.

The trick is, you can thus make your new option only be part of
EMAC_FTRS_POSSIBLE if support for a 460EX based board has been enabled
or even better, one that uses a GPCS PHY. You do that by creating a new
Kconfig option such as CONFIG_EMAC_SUPPORTS_GPCS for example that gets
select'ed by the boards that need it.

That way, when compiling a kernel for a board that does -not- need it,
the feature bit will be absent from EMAC_FTRS_POSSIBLE. That will allow
the compiler to figure out that when emac_has_feature() is called for
that option, the result will always be 0. Thus the compiler gets to
optimize out all the code relative to that option.

Cheers,
Ben.
