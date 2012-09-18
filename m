From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [V4 PATCH 0/8] csiostor: Chelsio FCoE offload driver submission
Date: Tue, 18 Sep 2012 09:36:14 +0100
Message-ID: <1347957374.2388.15.camel@dabdike.int.hansenpartnership.com>
References: <1347470328-32490-1-git-send-email-naresh@chelsio.com>
	 <5057F791.8020702@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <5057F791.8020702@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-09-18 at 09:54 +0530, Naresh Kumar Inna wrote:
> Hi James,
>=20
> Could you please consider merging version V4 of the driver patches, i=
f
> you think they are in good shape now?

Well, definitely not yet; you seem to have missed the memo on readq:

  CC [M]  drivers/scsi/cxgbi/cxgb4i/cxgb4i.o
drivers/scsi/csiostor/csio_hw.c: In function =E2=80=98csio_hw_mc_read=E2=
=80=99:
drivers/scsi/csiostor/csio_hw.c:194:3: error: implicit declaration of
function =E2=80=98readq=E2=80=99 [-Werror=3Dimplicit-function-declarati=
on]

It's only defined on platforms which can support an atomic 64 bit
operation (which is mostly not any 32 bit platforms) ... so this could
do with compile testing on those.

To see how to handle readq/writeq in the 32 bit case, see the uses in
fnic or qla2xxx

You also have a couple of unnecessary version.h includes.

Since you're a new driver, could you not do a correctly unlocked
queuecommand routine?  You'll find the way you've currently got it code=
d
(holding the host lock for the entire queuecommand routine) is very
performance detrimental.

You have a lot of locking statements which aren't easy to audit by hand
because there are multiple unlocks.  Things like this:

csio_scan_finished(struct Scsi_Host *shost, unsigned long time)
{
	struct csio_lnode *ln =3D shost_priv(shost);
	int rv =3D 0;

	spin_lock_irq(shost->host_lock);
	if (!ln->hwp || csio_list_deleted(&ln->sm.sm_list)) {
		spin_unlock_irq(shost->host_lock);
		return 1;
	}

	rv =3D csio_scan_done(ln, jiffies, time, csio_max_scan_tmo * HZ,
			    csio_delta_scan_tmo * HZ);

	spin_unlock_irq(shost->host_lock);

	return rv;
}

Are better coded as

csio_scan_finished(struct Scsi_Host *shost, unsigned long time)
{
	struct csio_lnode *ln =3D shost_priv(shost);
	int rv =3D 1;

	spin_lock_irq(shost->host_lock);
	if (!ln->hwp || csio_list_deleted(&ln->sm.sm_list))
		goto out;

	rv =3D csio_scan_done(ln, jiffies, time, csio_max_scan_tmo * HZ,
			    csio_delta_scan_tmo * HZ);

 out:
	spin_unlock_irq(shost->host_lock);

	return rv;
}

It's shorter and the unlock clearly matches the lock.  You could even
invert the if logic and just make the csio_scan_done() conditional on i=
t
avoiding the goto.

I'd also really like the people who understand FC to take a look over
this as well.

James


--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
