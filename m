From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/7] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Wed, 25 Jun 2014 06:56:08 +0200
Message-ID: <20140625045607.GC3845@localhost.localdomain>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
 <1403624632-17327-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:41498 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaFYE4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 00:56:33 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so7115627wib.5
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 21:56:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1403624632-17327-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 11:43:46AM -0400, Willem de Bruijn wrote:

> The code is backward compatible with legacy applications that treat
> the ancillary data as an anonymous array 'struct timespec data[3]'.
> It will break applications that test the size of the cmsg data.

I think this introduces an unacceptable ABI change.
In linuxptp we have

		if (SOL_SOCKET == level && SO_TIMESTAMPING == type) {
			if (cm->cmsg_len < sizeof(*ts) * 3) {
				pr_warning("short SO_TIMESTAMPING message");
				return -1;
			}
			ts = (struct timespec *) CMSG_DATA(cm);
		}

but other applications might barf if the length isn't exactly right.

> +/**
> + *	struct sock_errqueue_timestamping - timestamps exposed through cmsg
> + *
> + *	The timestamping interfaces SO_TIMESTAMPING, MSG_TSTAMP_*
> + *	communicate network timestamps to userspace by passing this struct
> + *	through a cmsg in recvmsg().
> + *
> + *	@ts_sw:     the sw timestamp: the contents depends on ts_type.

This would overload the field. I don't like that.

> + *	@ts_hw_sys: a hardware generated timestamp converted to system time.
> + *	@ts_hw_raw: a hardware generated timestamp converted in its raw format.
> + *	@ts_type:   the type of timestamp ts_sw. One of SCM_TSTAMP_*
> + *	@ts_key:    socket flow index that the timestamps correspond to
> + *		    (stream transport protocols only, e.g., TCP seqno)
> + *
> + *	The first three fields are dictated by historical use. The hardware
> + *	timestamps are empty unless hardware timestamping is enabled, but
> + *	they have to be present in each message.
> + */
> +struct sock_errqueue_timestamping {
> +	struct timespec ts_sw;
> +	struct timespec ts_hw_sys;
> +	struct timespec ts_hw_raw;
> +	__u32 ts_key;
> +	__u16 ts_type;
> +	__u16 ts_padding;
> +};
> +
> +enum {
> +	SCM_TSTAMP_SND = 1,
> +	SCM_TSTAMP_ACK = 2,
> +	SCM_TSTAMP_ENQ = 3
> +};

So why not simply introduce a new kind of CMSG for these new time
stamps? It appears that the use case for these is totally different
than for SO_TIMESTAMPING. I can't imagine why you would want to mix
them together.

Thanks,
Richard
