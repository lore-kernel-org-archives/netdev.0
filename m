From: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH V2 2/2] qedf: Add QLogic FastLinQ offload
 FCoE driver framework.
Date: Wed, 1 Feb 2017 08:59:36 +0100
Message-ID: <2203e514-5ca8-28e2-af22-537899407cf9@suse.de>
References: <1485376423-18737-1-git-send-email-chad.dupuis@cavium.com>
 <1485376423-18737-3-git-send-email-chad.dupuis@cavium.com>
 <28df9087-4eaf-d72c-ccee-89408d3a1b32@suse.de>
 <alpine.OSX.2.00.1701311156290.1169@administrators-macbook-pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
 QLogic-Storage-Upstream-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Chad Dupuis <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <alpine.OSX.2.00.1701311156290.1169-nVgGmETfwnIFUnR/tdpssI0aTaFgKE92ACYyPGjX6YU@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel/>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: "fcoe-devel" <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 01/31/2017 06:08 PM, Chad Dupuis wrote:
>
> On Mon, 30 Jan 2017, 10:34am -0000, Hannes Reinecke wrote:
>
>> On 01/25/2017 09:33 PM, Dupuis, Chad wrote:
>>> From: "Dupuis, Chad" <chad.dupuis-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>>>
[ .. ]
>>> +	if (opcode =3D=3D ELS_LS_RJT) {
>>> +		rjt =3D fc_frame_payload_get(fp, sizeof(*rjt));
>>> +		QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
>>> +		    "Received LS_RJT for REC: er_reason=3D0x%x, "
>>> +		    "er_explan=3D0x%x.\n", rjt->er_reason, rjt->er_explan);
>>> +		/*
>>> +		 * The following response(s) mean that we need to reissue the
>>> +		 * request on another exchange.  We need to do this without
>>> +		 * informing the upper layers lest it cause an application
>>> +		 * error.
>>> +		 */
>>> +		if ((rjt->er_reason =3D=3D ELS_RJT_LOGIC ||
>>> +		    rjt->er_reason =3D=3D ELS_RJT_UNAB) &&
>>> +		    rjt->er_explan =3D=3D ELS_EXPL_OXID_RXID) {
>>> +			QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_ELS,
>>> +			    "Handle CMD LOST case.\n");
>>> +			qedf_requeue_io_req(orig_io_req);
>>> +		}
>>
>> Care to explain this?
>> I found requeing within the driver without notifying the upper layers
>> deeply troubling.
>> I've came across this (or a similar issue) during implementing
>> FCoE over virtio; there it turned out to be an issue with the target not
>> handling frames in the correct order.
>> So it looks you are attempting to solve the problem of a REC being sent
>> for a command which is not know at the target.
>> Meaning it's either lost in the fabric, hasn't been seen by the target
>> (yet), or having already been processed by the target.
>>
>> The above code would only solve the second problem; however, that would
>> indicate a command ordering issue as the REC would have arrived at the
>> target _before_ the originating command.
>> So doing a resend would only help for _that_ specific case, not for the
>> others.
>> And it's not quite clear why resending with a different OXID would help
>> here; typically it's the _RXID_ which isn't found ...
>
> The problem I've observed is that If I return an error to the SCSI layer
> it propogates up to the st driver and the test application would fail
> since st would fail the I/O.  As the comment explains we do this on
> another exchange internally in the driver so as not to cause the tape
> backup application/test to fail.
>
> bnx2fc behaves like this IIRC.
>
Ah, yes.
I've had this discussion with James Smart, too.
When a command abort fails with 'Invalid OXID/RXID' we should be =

retrying the command with a different set of IDs, as the original
need to quarantined.
(Which, incidentaily, you don't do, right? You cannot re-use that =

particular exchange until you either got a response for it or you reset =

the exchange manager. If you don't you run into the risk of getting an =

invalid completion if for some reason the command _does_ return =

eventually...)

Even though I'd rather like to have it resolved in libfc or even the =

SCSI midlayer itself, it's not something which should hold off the =

entire submission.

>>
>> [ .. ]
>>> +static void qedf_fcoe_process_vlan_resp(struct qedf_ctx *qedf,
>>> +	struct sk_buff *skb)
>>> +{
>>> +	struct fip_header *fiph;
>>> +	struct fip_desc *desc;
>>> +	u16 vid =3D 0;
>>> +	ssize_t rlen;
>>> +	size_t dlen;
>>> +
>>> +	fiph =3D (struct fip_header *)(((void *)skb->data) + 2 * ETH_ALEN + 2=
);
>>> +
>>> +	rlen =3D ntohs(fiph->fip_dl_len) * 4;
>>> +	desc =3D (struct fip_desc *)(fiph + 1);
>>> +	while (rlen > 0) {
>>> +		dlen =3D desc->fip_dlen * FIP_BPW;
>>> +		switch (desc->fip_dtype) {
>>> +		case FIP_DT_VLAN:
>>> +			vid =3D ntohs(((struct fip_vlan_desc *)desc)->fd_vlan);
>>> +			break;
>>> +		}
>>> +		desc =3D (struct fip_desc *)((char *)desc + dlen);
>>> +		rlen -=3D dlen;
>>> +	}
>>> +
>>> +	QEDF_INFO(&(qedf->dbg_ctx), QEDF_LOG_DISC, "VLAN response, "
>>> +		   "vid=3D0x%x.\n", vid);
>>> +
>>> +	if (vid > 0 && qedf->vlan_id !=3D vid) {
>>> +		qedf_set_vlan_id(qedf, vid);
>>> +
>>> +		/* Inform waiter that it's ok to call fcoe_ctlr_link up() */
>>> +		complete(&qedf->fipvlan_compl);
>>> +	}
>>> +}
>>> +
>> As mentioned, this will fail for HP VirtualConnect, which return a vid
>> of '0', indicating that the FCoE link should run on the interface itself.
>> And this is actually a valid response, I would think that you should be
>> calling complete() for any response ...
>
> In testing I would get responses that would seem to contain VID 0 but then
> subsequent responses contain the valid VID.  If I try to go with a VID of
> 0 FIP discovery would fail.  It could be possible that there's a bug in
> the code that parses the FIP VLAN response but I'll like to leave this in
> for now and it can be removed once I figure where the issue may be.
>
Okay.

Cheers,

Hannes
-- =

Dr. Hannes Reinecke		      zSeries & Storage
hare-l3A5Bk7waGM@public.gmane.org			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
GF: J. Hawn, J. Guild, F. Imend=F6rffer, HRB 16746 (AG N=FCrnberg)
