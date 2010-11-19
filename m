From: Mark Lord <kernel-R6A+fiHC8nRWk0Htik3J/w@public.gmane.org>
Subject: Re: 2.6.37-rc2-git4: Reported regressions 2.6.35 -> 2.6.36
Date: Fri, 19 Nov 2010 17:55:42 -0500
Message-ID: <4CE7006E.4040102@teksavvy.com>
References: <tTUH_XeInOH.A.dMF.c3b5MB@chimera>	<4CE5C919.7090504@teksavvy.com> <AANLkTi=8G7pNA7QTxaXDWKrWrCERPfmKU+nLJWCA=JUH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Alex Deucher <alexdeucher-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTi=8G7pNA7QTxaXDWKrWrCERPfmKU+nLJWCA=JUH-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10-11-19 11:39 AM, Alex Deucher wrote:
> On Thu, Nov 18, 2010 at 7:47 PM, Mark Lord<kernel-R6A+fiHC8nRWk0Htik3J/w@public.gmane.org>  wrote:
>
>> My non-Intel graphics notebook (has ATI X1400 graphics) also has a resume
>> regression with 2.6.36.  But it does work fine with 2.6.35 (and earlier,
>> back many years).  As a result, I'm stuck with 2.6.35 for the time being,
>> and lack the time for a concerted debug effort on 2.6.36+ right now.
>>
>
> Can you bisect?  Does this patch help?
>
> diff --git a/drivers/gpu/drm/radeon/atom.c b/drivers/gpu/drm/radeon/atom.c
> index 8e421f6..05efb5b 100644
> --- a/drivers/gpu/drm/radeon/atom.c
> +++ b/drivers/gpu/drm/radeon/atom.c
> @@ -112,6 +112,7 @@ static uint32_t atom_iio_execute(struct
> atom_context *ctx, int base,
>                          base += 3;
>                          break;
>                  case ATOM_IIO_WRITE:
> +                       (void)ctx->card->ioreg_read(ctx->card, CU16(base + 1));
>                          ctx->card->ioreg_write(ctx->card, CU16(base + 1), temp);
>                          base += 3;
>                          break;

It now comes back at resume time.

But suffers long delays (also sometimes with 2.6.35) doing this:

[drm:atom_op_jump] *ERROR* atombios stuck in loop for more than 5secs aborting
[drm:atom_execute_table_locked] *ERROR* atombios stuck executing E576 (len 105, 
WS 12, PS 8) @ 0xE5C4
[drm:atom_op_jump] *ERROR* atombios stuck in loop for more than 5secs aborting
[drm:atom_execute_table_locked] *ERROR* atombios stuck executing ECD2 (len 86, 
WS 4, PS 0) @ 0xED05
[drm:atom_op_jump] *ERROR* atombios stuck in loop for more than 5secs aborting
[drm:atom_execute_table_locked] *ERROR* atombios stuck executing E576 (len 105, 
WS 12, PS 8) @ 0xE5C4
PM: resume of devices complete after 15718.253 msecs

So I did this (local hack only, obviously NOT for mainline) to work around that 
issue:

--- linux-2.6.36/drivers/gpu/drm/radeon/atom.c  2010-10-20 16:30:22.000000000 -0400
+++ linux/drivers/gpu/drm/radeon/atom.c 2010-11-19 17:14:21.141807003 -0500
@@ -1150,6 +1151,7 @@

         if (!base)
                 return -EINVAL;
+       if (base == 0xe576 || base == 0xecd2) return 0;  /* prevent freezes on 
Dell i9400 w/X1400 */

         len = CU16(base + ATOM_CT_SIZE_PTR);
         ws = CU8(base + ATOM_CT_WS_PTR);
