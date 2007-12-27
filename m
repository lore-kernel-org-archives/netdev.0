From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Thu, 27 Dec 2007 17:51:49 +0900
Message-ID: <20071227173802.6F56.40F06B3A@sm.sony.co.jp>
References: <20071221.205808.213484078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071221.205808.213484078.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

	Hi

On Fri, 21 Dec 2007 20:58:08 -0800 (PST)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> @@ -520,7 +530,7 @@ iwe_stream_add_point(char *	stream,		/* Stream of events */
>  		memcpy(stream + IW_EV_LCP_LEN,
>  		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
>  		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);

As the alignment of 64bit platforms may be defferent from 32bit one,
should it be like the following?

static inline char *
iwe_stream_add_point(char *	stream,		/* Stream of events */
		     char *	ends,		/* End of stream */
		     struct iw_event *iwe,	/* Payload length + flags */
		     char *	extra,		/* More payload */
		     struct iw_request_info *info)
{
	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
	int	point_len = IW_EV_POINT_LEN;
	int	lcp_len = IW_EV_LCP_LEN;

#ifdef CONFIG_COMPAT
	if (info->flags & IW_REQUEST_FLAG_COMPAT) {
		event_len = IW_EV_COMPAT_POINT_LEN + iwe->u.data.length;
		point_len = IW_EV_COMPAT_POINT_LEN;
		lcp_len = IW_EV_COMPAT_LCP_LEN;
	}
#endif

	/* Check if it's possible */
	if(likely((stream + event_len) < ends)) {
		iwe->len = event_len;
		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
		memcpy(stream + lcp_len,
		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
		memcpy(stream + point_len, extra, iwe->u.data.length);
		stream += event_len;
	}
	return stream;
}

(Note that IW_EV_COMPAT_LCP_LEN is just a example; not defined anywhere)

-- 
Masakazu MOKUNO
