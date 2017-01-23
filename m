From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv3 net-next 4/4] sctp: implement sender-side procedures
 for Add Incoming/Outgoing Streams Request Parameter
Date: Mon, 23 Jan 2017 11:25:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB026B563@AcuExch.aculab.com>
References: <cover.1484845510.git.lucien.xin@gmail.com>
 <daa150a23548dda0a2fd513c622773f0ff9b2df3.1484845510.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Xin Long' <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:61779 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAWLbO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 06:31:14 -0500
In-Reply-To: <daa150a23548dda0a2fd513c622773f0ff9b2df3.1484845510.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long
> Sent: 19 January 2017 17:19
> This patch is to implement Sender-Side Procedures for the Add
> Outgoing and Incoming Streams Request Parameter described in
> rfc6525 section 5.1.5-5.1.6.
> 
> It is also to add sockopt SCTP_ADD_STREAMS in rfc6525 section
> 6.3.4 for users.
...
> +	out = params->sas_outstrms;
> +	in  = params->sas_instrms;
> +
> +	if (!out && !in)
> +		goto out;
> +
> +	if (out) {
> +		__u16 nums = stream->outcnt + out;

Make nums 'unsigned int', the code will be smaller and you can
use the value for the overflow check.

> +		/* Check for overflow, can't use nums here */
> +		if (stream->outcnt + out > SCTP_MAX_STREAM)
> +			goto out;
> +
> +		/* Use ksize to check if stream array really needs to realloc */
> +		if (ksize(stream->out) / sizeof(*stream->out) < nums) {
> +			struct sctp_stream_out *streamout;
> +
> +			streamout = kcalloc(nums, sizeof(*streamout),
> +					    GFP_KERNEL);
> +			if (!streamout) {
> +				retval = -ENOMEM;
> +				goto out;
> +			}
> +
> +			memcpy(streamout, stream->out,
> +			       sizeof(*streamout) * stream->outcnt);
> +
> +			kfree(stream->out);
> +			stream->out = streamout;
> +		}

Does kcalloc() zero the entire area, or just the length you ask for?
If the latter you need to zero the rest here.
...

	David
