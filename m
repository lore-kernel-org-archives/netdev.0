From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: prevent division by zero if
	TIMINCA is zero
Date: Fri, 6 May 2016 23:43:17 +0000
Message-ID: <5E18E4A4-E10F-46B5-A2F5-FCA10FAA5030@intel.com>
References: <1462563711-30350-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_61D6A58B-1F97-4278-A1A2-C2126EAE927C";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44064 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758844AbcEFXnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 19:43:19 -0400
In-Reply-To: <1462563711-30350-1-git-send-email-dvlasenk@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_61D6A58B-1F97-4278-A1A2-C2126EAE927C
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Denys Vlasenko <dvlasenk@redhat.com> wrote:

> Users report that under VMWare, er32(TIMINCA) returns zero.
> This causes division by zero at init time as follows:
>
>  ==>            incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
>                 for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
>                         /* latch SYSTIMH on read of SYSTIML */
>                         systim_next = (cycle_t)er32(SYSTIML);
>                         systim_next |= (cycle_t)er32(SYSTIMH) << 32;
>
>                         time_delta = systim_next - systim;
>                         temp = time_delta;
>  ====>                  rem = do_div(temp, incvalue);
>
> This change makes kernel survive this, and users report that
> NIC does work after this change.
>
> Since on real hardware incvalue is never zero, this should not affect
> real hardware use case.
>
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: "Ruinskiy, Dima" <dima.ruinskiy@intel.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> CC: LKML <linux-kernel@vger.kernel.org>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c  
> b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 269087c..0626935 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -4315,7 +4315,8 @@ static cycle_t e1000e_cyclecounter_read(const  
> struct cyclecounter *cc)
>
>  			time_delta = systim_next - systim;
>  			temp = time_delta;
> -			rem = do_div(temp, incvalue);
> +			/* VMWare users have seen incvalue of zero, don't div / 0 */
> +			rem = incvalue ? do_div(temp, incvalue) : (time_delta != 0);
>
>  			systim = systim_next;
>

I seem to recall that this was rejected before because it really is  
VMWare's bug and, if they fix it, any existing VMs that use this will just  
work. Changing the driver will only fix it for vms that install a new  
driver. I don't object to doing it, it just seems like not the most  
effective place to address the issue.
--Apple-Mail=_61D6A58B-1F97-4278-A1A2-C2126EAE927C--
