From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH 4/4] bnx2i: Add bnx2i iSCSI driver.
Date: Wed, 06 May 2009 11:48:42 -0500
Message-ID: <4A01BF6A.90707@cs.wisc.edu>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com> <1241208039-6813-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, James.Bottomley@HansenPartnership.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Karen Xie <kxie@chelsio.com>,
	Jayamohan Kalickal <jayamohank@serverengines.com>
To: open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:44130 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754706AbZEFQsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 12:48:54 -0400
In-Reply-To: <1241208039-6813-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +
> +/**
> + * bnx2i_nl_mesg_recv -
> + * @buf:	pointer to buffer containing vendor specific message
> + * @buf:	buffer length
> + *
> + */
> +static int bnx2i_nl_mesg_recv(struct Scsi_Host *shost, uint16_t priv_op,
> +			      int status, char *buf, int buflen)
> +{
> +	struct bnx2i_hba *hba = iscsi_host_priv(shost);
> +
> +	switch (priv_op) {
> +	case NX2_UIO_UEVENT_NEIGH_LOOKUP:
> +	default:
> +		/* handle by cnic driver */
> +		hba->cnic->nl_priv_msg_recv(hba->cnic, priv_op, buf, buflen);
> +		break;
> +	}
> +
> +	return buflen;
> +}

I think I was wrong with one of the comments I gave you.

It seems like we have two iscsi net config models.

1. qla4xxx and Server Engines type of setup where the driver just tells 
the card to use some ip or do dhcp and some other net settings and it 
does all the net magic. The iscsi driver does not have to worry about 
anything like the dhcp process or arp. It only passes down the setup values.

2. cxgb3i and bnx2i type of model where kernel or userspace code is 
needed to execute many net operations.
- Right now, cxgb3i sort of cheated :) and only supports static IPs. It 
currently uses the iscsi set param interface to do this.

- bnx2i wants to add more complicated features and is going to do them 
in userspace. It us using the private messages that were added in the 
previous patch.


I think cxgb3i is one day going to want to support the same features 
bnx2i does. If that is right, then should we just make the NX2_UIO 
events common iscsi events, and hook cxb3i in? It would not use the 
iscsi set param interface at all and would work just like bnx2i. Is that 
possible? What about future drivers? Are done making iscsi cards and 
drivers. If so, thank goodness :)  If not then maybe we want to consider 
some future driver using the #2 module and possibly using this.

If cxgb3i is really only going to support static ip setup and we think 
that bnx2i is going to be unique on how it sets up the network then I 
NX2_UIO private events are fine. Or is this a case of we are thinking 
that iscsi hardware people are creating crazy interfaces so there is no 
why to predict what they are going to do so there is no point in trying 
to design for them.
