From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Fri, 11 Jan 2008 13:16:29 +0900
Message-ID: <20080111112248.610C.40F06B3A@sm.sony.co.jp>
References: <20071227181439.6F59.40F06B3A@sm.sony.co.jp> <20080110.011602.74511551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------_4786D2F80000000062DA_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080110.011602.74511551.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--------_4786D2F80000000062DA_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

	Hi

Thank you for updating the patch.

On Thu, 10 Jan 2008 01:16:02 -0800 (PST)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
> Date: Thu, 27 Dec 2007 18:24:40 +0900
> 
> > On ppc64 (PS3), IW_EV_LCP_LEN is 8, not 4.
> > 
> > include/linux/wireless.h:
> > 
> > #define IW_EV_LCP_LEN   (sizeof(struct iw_event) - sizeof(union iwreq_data))
> > 
> > where sizeof(struct iw_event) == 24, sizeof(union iwreq_data) == 16 on
> > PS3.
> 
> Here is a new version of the last patch (#12), it should handle
> all of these cases properly now.
> 
> Let me know if you spot any more errors.
> 
> Thanks!
> 
> [WEXT]: Emit event stream entries correctly when compat.
> 
> Three major portions to this change:
> 
> 1) Add IW_EV_COMPAT_LCP_LEN, IW_EV_COMPAT_POINT_OFF,
>    and IW_EV_COMPAT_POINT_LEN helper defines.
> 
> 2) Delete iw_stream_check_add_*(), they are unused.
> 
> 3) Add iw_request_info argument to iwe_stream_add_*(), and use it to
>    size the event and pointer lengths correctly depending upon whether
>    IW_REQUEST_FLAG_COMPAT is set or not.
> 
> 4) The mechanical transformations to the drivers and wireless stack
>    bits to get the iw_request_info passed down into the routines
>    modified in #3.
> 
> With help from Masakazu Mokuno
> 
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  drivers/net/wireless/airo.c                |   39 +++++---
>  drivers/net/wireless/atmel.c               |   24 ++++-
>  drivers/net/wireless/hostap/hostap.h       |    3 +-
>  drivers/net/wireless/hostap/hostap_ap.c    |   32 +++---
>  drivers/net/wireless/hostap/hostap_ioctl.c |   54 ++++++-----
>  drivers/net/wireless/libertas/scan.c       |   35 ++++---
>  drivers/net/wireless/orinoco.c             |   30 ++++--
>  drivers/net/wireless/prism54/isl_ioctl.c   |   45 +++++----
>  drivers/net/wireless/wl3501_cs.c           |   10 +-
>  drivers/net/wireless/zd1201.c              |   21 +++--
>  include/linux/wireless.h                   |   16 +++
>  include/net/iw_handler.h                   |  150 ++++++++--------------------
>  net/ieee80211/ieee80211_wx.c               |   44 +++++----
>  net/mac80211/ieee80211_i.h                 |    5 +-
>  net/mac80211/ieee80211_ioctl.c             |    2 +-
>  net/mac80211/ieee80211_sta.c               |   59 ++++++-----
>  16 files changed, 293 insertions(+), 276 deletions(-)

[snip]

> diff --git a/include/linux/wireless.h b/include/linux/wireless.h
> index 2088524..bec73df 100644
> --- a/include/linux/wireless.h
> +++ b/include/linux/wireless.h
> @@ -1098,6 +1098,22 @@ struct iw_event
>  #define IW_EV_POINT_LEN	(IW_EV_LCP_LEN + sizeof(struct iw_point) - \
>  			 IW_EV_POINT_OFF)
>  
> +#if defined(__KERNEL__) && defined(CONFIG_COMPAT)
> +struct __compat_iw_event {
> +	__u16		len;			/* Real lenght of this stuff */
                                                         ~~~~~
length?

> +	__u16		cmd;			/* Wireless IOCTL */
> +	compat_caddr_t	pointer;
> +};
> +#define IW_EV_COMPAT_LCP_LEN \
> +	(sizeof(struct __compat_iw_event) - sizeof(compat_caddr_t))
> +#define IW_EV_COMPAT_POINT_OFF (((char *) \
> +			  &(((struct compat_iw_point *) NULL)->length)) - \
> +			  (char *) NULL)

How about the followings?

#define IW_EV_COMPAT_LCP_LEN offsetof(struct __compat_iw_event, pointer)
#define IW_EV_COMPAT_POINT_OFF offsetof(struct compat_iw_point, length)

> +#define IW_EV_COMPAT_POINT_LEN	\
> +	(IW_EV_COMPAT_LCP_LEN + sizeof(struct compat_iw_point) - \
> +	 IW_EV_COMPAT_POINT_OFF)
> +#endif
> +
>  /* Size of the Event prefix when packed in stream */
>  #define IW_EV_LCP_PK_LEN	(4)
>  /* Size of the various events when packed in stream */
> diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
> index c99a8ee..d6f0c51 100644
> --- a/include/net/iw_handler.h
> +++ b/include/net/iw_handler.h
> @@ -483,19 +483,26 @@ extern void wireless_spy_update(struct net_device *	dev,
>   * Wrapper to add an Wireless Event to a stream of events.
>   */
>  static inline char *
> -iwe_stream_add_event(char *	stream,		/* Stream of events */
> -		     char *	ends,		/* End of stream */
> -		     struct iw_event *iwe,	/* Payload */
> -		     int	event_len)	/* Real size of payload */
> +iwe_stream_add_event(struct iw_request_info *info, char *stream, char *ends,
> +		     struct iw_event *iwe, int event_len)
>  {
> +	int lcp_len = IW_EV_LCP_LEN;
> +
> +#ifdef CONFIG_COMPAT
> +	if (info->flags & IW_REQUEST_FLAG_COMPAT) {
> +		event_len -= IW_EV_LCP_LEN;
> +		event_len += IW_EV_COMPAT_LCP_LEN;
> +		lcp_len = IW_EV_COMPAT_LCP_LEN;
> +	}
> +#endif
>  	/* Check if it's possible */
>  	if(likely((stream + event_len) < ends)) {
>  		iwe->len = event_len;
>  		/* Beware of alignement issues on 64 bits */
>  		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
> -		memcpy(stream + IW_EV_LCP_LEN,
> -		       ((char *) iwe) + IW_EV_LCP_LEN,
> -		       event_len - IW_EV_LCP_LEN);
> +		memcpy(stream + lcp_len,
> +		       ((char *) iwe) + lcp_len,

The source address does not have to be adjusted.  I think it should be
		       ((char *) iwe) + IW_EV_LCP_LEN,
or just
		       &iwe->u
I think it is more readable what we want to do here.


> +		       event_len - lcp_len);

The length of the real payload does not need to take account of the
destination offset change.  So we can keep the original code like:

		       org_event_len - IW_EV_LCP_LEN);

>  		stream += event_len;
>  	}
>  	return stream;
> @@ -507,104 +514,33 @@ iwe_stream_add_event(char *	stream,		/* Stream of events */
>   * stream of events.
>   */
>  static inline char *
> -iwe_stream_add_point(char *	stream,		/* Stream of events */
> -		     char *	ends,		/* End of stream */
> -		     struct iw_event *iwe,	/* Payload length + flags */
> -		     char *	extra)		/* More payload */
> +iwe_stream_add_point(struct iw_request_info *info, char *stream, char *ends,
> +		     struct iw_event *iwe, char *extra)
>  {
> -	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
> -	/* Check if it's possible */
> -	if(likely((stream + event_len) < ends)) {
> -		iwe->len = event_len;
> -		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
> -		memcpy(stream + IW_EV_LCP_LEN,
> -		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
> -		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
> -		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
> -		stream += event_len;
> +	int event_len = IW_EV_POINT_LEN + iwe->u.data.length;
> +	int point_len = IW_EV_POINT_LEN;
> +	int lcp_len = IW_EV_LCP_LEN;
> +	int point_off = IW_EV_POINT_OFF;
> +
> +#ifdef CONFIG_COMPAT
> +	if (info->flags & IW_REQUEST_FLAG_COMPAT) {
> +		event_len = IW_EV_COMPAT_POINT_LEN + iwe->u.data.length;
> +		point_len = IW_EV_COMPAT_POINT_LEN;
> +		lcp_len = IW_EV_COMPAT_LCP_LEN;
> +		point_off = IW_EV_COMPAT_POINT_OFF;
>  	}
> -	return stream;
> -}
> -
> -/*------------------------------------------------------------------*/
> -/*
> - * Wrapper to add a value to a Wireless Event in a stream of events.
> - * Be careful, this one is tricky to use properly :
> - * At the first run, you need to have (value = event + IW_EV_LCP_LEN).
> - */
> -static inline char *
> -iwe_stream_add_value(char *	event,		/* Event in the stream */
> -		     char *	value,		/* Value in event */
> -		     char *	ends,		/* End of stream */
> -		     struct iw_event *iwe,	/* Payload */
> -		     int	event_len)	/* Real size of payload */
> -{
> -	/* Don't duplicate LCP */
> -	event_len -= IW_EV_LCP_LEN;
> +#endif
>  
>  	/* Check if it's possible */
> -	if(likely((value + event_len) < ends)) {
> -		/* Add new value */
> -		memcpy(value, (char *) iwe + IW_EV_LCP_LEN, event_len);
> -		value += event_len;
> -		/* Patch LCP */
> -		iwe->len = value - event;
> -		memcpy(event, (char *) iwe, IW_EV_LCP_LEN);
> -	}
> -	return value;
> -}
> -
> -/*------------------------------------------------------------------*/
> -/*
> - * Wrapper to add an Wireless Event to a stream of events.
> - * Same as above, with explicit error check...
> - */
> -static inline char *
> -iwe_stream_check_add_event(char *	stream,		/* Stream of events */
> -			   char *	ends,		/* End of stream */
> -			   struct iw_event *iwe,	/* Payload */
> -			   int		event_len,	/* Size of payload */
> -			   int *	perr)		/* Error report */
> -{
> -	/* Check if it's possible, set error if not */
>  	if(likely((stream + event_len) < ends)) {
>  		iwe->len = event_len;
> -		/* Beware of alignement issues on 64 bits */
>  		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
> -		memcpy(stream + IW_EV_LCP_LEN,
> -		       ((char *) iwe) + IW_EV_LCP_LEN,
> -		       event_len - IW_EV_LCP_LEN);
> -		stream += event_len;
> -	} else
> -		*perr = -E2BIG;
> -	return stream;
> -}
> -
> -/*------------------------------------------------------------------*/
> -/*
> - * Wrapper to add an short Wireless Event containing a pointer to a
> - * stream of events.
> - * Same as above, with explicit error check...
> - */
> -static inline char *
> -iwe_stream_check_add_point(char *	stream,		/* Stream of events */
> -			   char *	ends,		/* End of stream */
> -			   struct iw_event *iwe,	/* Payload length + flags */
> -			   char *	extra,		/* More payload */
> -			   int *	perr)		/* Error report */
> -{
> -	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
> -	/* Check if it's possible */
> -	if(likely((stream + event_len) < ends)) {
> -		iwe->len = event_len;
> -		memcpy(stream, (char *) iwe, IW_EV_LCP_PK_LEN);
> -		memcpy(stream + IW_EV_LCP_LEN,
> -		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
> +		memcpy(stream + lcp_len,
> +		       ((char *) iwe) + lcp_len + point_off,

Same as iwe_stream_add_event().  Source address does not need to be
fixed.

>  		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
> -		memcpy(stream + IW_EV_POINT_LEN, extra, iwe->u.data.length);
> +		memcpy(stream + point_len, extra, iwe->u.data.length);
>  		stream += event_len;
> -	} else
> -		*perr = -E2BIG;
> +	}
>  	return stream;
>  }
>  
> @@ -613,29 +549,29 @@ iwe_stream_check_add_point(char *	stream,		/* Stream of events */
>   * Wrapper to add a value to a Wireless Event in a stream of events.
>   * Be careful, this one is tricky to use properly :
>   * At the first run, you need to have (value = event + IW_EV_LCP_LEN).
> - * Same as above, with explicit error check...
>   */
>  static inline char *
> -iwe_stream_check_add_value(char *	event,		/* Event in the stream */
> -			   char *	value,		/* Value in event */
> -			   char *	ends,		/* End of stream */
> -			   struct iw_event *iwe,	/* Payload */
> -			   int		event_len,	/* Size of payload */
> -			   int *	perr)		/* Error report */
> +iwe_stream_add_value(struct iw_request_info *info, char *event, char *value,
> +		     char *ends, struct iw_event *iwe, int event_len)
>  {
> +	int lcp_len = IW_EV_LCP_LEN;
> +
> +#ifdef CONFIG_COMPAT
> +	if (info->flags & IW_REQUEST_FLAG_COMPAT)
> +		lcp_len = IW_EV_COMPAT_LCP_LEN;
> +#endif
>  	/* Don't duplicate LCP */
>  	event_len -= IW_EV_LCP_LEN;
>  
>  	/* Check if it's possible */
>  	if(likely((value + event_len) < ends)) {
>  		/* Add new value */
> -		memcpy(value, (char *) iwe + IW_EV_LCP_LEN, event_len);
> +		memcpy(value, (char *) iwe + lcp_len, event_len);

Same as iwe_stream_add_event(). We can keep the original code.

>  		value += event_len;
>  		/* Patch LCP */
>  		iwe->len = value - event;
> -		memcpy(event, (char *) iwe, IW_EV_LCP_LEN);
> -	} else
> -		*perr = -E2BIG;
> +		memcpy(event, (char *) iwe, lcp_len);
> +	}
>  	return value;
>  }


iwe_stream_add_value() is a bit tricky, so callers of this function
should do some adjusting work.  For example,
ieee80211_translate_scan():ieee80211_wx.c needs like:

 	/* Add basic and extended rates */
 	/* Rate : stuffing multiple values in a single event require a bit
 	 * more of magic - Jean II */
+#ifdef CONFIG_COMPAT
+	if (info->flags & IW_REQUEST_FLAG_COMPAT)
+		current_val = start + IW_EV_COMPAT_LCP_LEN;
+	else
+		current_val = start + IW_EV_LCP_LEN;
+#else
 	current_val = start + IW_EV_LCP_LEN;
+#endif
 	iwe.cmd = SIOCGIWRATE;
 	/* Those two flags are ignored... */
 	iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;


I tried to make the patch that was incorporated with my comments above and
tested it with zd1211 based USB wireless adapter on my PS3.  It seemed
that the scan result prints from iwlist was OK.  The attached is the
patch. 
But wpa_supplicant did not work properly with it.  Although I did not
look it closely, it seemed that wpa_supplicant got a NULL IWAP event
when associated.


-- 
Masakazu MOKUNO

--------_4786D2F80000000062DA_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="davem-12-modified.patch"
Content-Disposition: attachment;
 filename="davem-12-modified.patch"
Content-Transfer-Encoding: base64

SGVyZSBpcyBhIG5ldyB2ZXJzaW9uIG9mIHRoZSBsYXN0IHBhdGNoICgjMTIpLCBpdCBzaG91bGQg
aGFuZGxlCmFsbCBvZiB0aGVzZSBjYXNlcyBwcm9wZXJseSBub3cuCgpMZXQgbWUga25vdyBpZiB5
b3Ugc3BvdCBhbnkgbW9yZSBlcnJvcnMuCgpUaGFua3MhCgpbV0VYVF06IEVtaXQgZXZlbnQgc3Ry
ZWFtIGVudHJpZXMgY29ycmVjdGx5IHdoZW4gY29tcGF0LgoKVGhyZWUgbWFqb3IgcG9ydGlvbnMg
dG8gdGhpcyBjaGFuZ2U6CgoxKSBBZGQgSVdfRVZfQ09NUEFUX0xDUF9MRU4sIElXX0VWX0NPTVBB
VF9QT0lOVF9PRkYsCiAgIGFuZCBJV19FVl9DT01QQVRfUE9JTlRfTEVOIGhlbHBlciBkZWZpbmVz
LgoKMikgRGVsZXRlIGl3X3N0cmVhbV9jaGVja19hZGRfKigpLCB0aGV5IGFyZSB1bnVzZWQuCgoz
KSBBZGQgaXdfcmVxdWVzdF9pbmZvIGFyZ3VtZW50IHRvIGl3ZV9zdHJlYW1fYWRkXyooKSwgYW5k
IHVzZSBpdCB0bwogICBzaXplIHRoZSBldmVudCBhbmQgcG9pbnRlciBsZW5ndGhzIGNvcnJlY3Rs
eSBkZXBlbmRpbmcgdXBvbiB3aGV0aGVyCiAgIElXX1JFUVVFU1RfRkxBR19DT01QQVQgaXMgc2V0
IG9yIG5vdC4KCjQpIFRoZSBtZWNoYW5pY2FsIHRyYW5zZm9ybWF0aW9ucyB0byB0aGUgZHJpdmVy
cyBhbmQgd2lyZWxlc3Mgc3RhY2sKICAgYml0cyB0byBnZXQgdGhlIGl3X3JlcXVlc3RfaW5mbyBw
YXNzZWQgZG93biBpbnRvIHRoZSByb3V0aW5lcwogICBtb2RpZmllZCBpbiAjMy4KCldpdGggaGVs
cCBmcm9tIE1hc2FrYXp1IE1va3VubwoKU2lnbmVkLW9mZi1ieTogRGF2aWQgUy4gTWlsbGVyIDxk
YXZlbUBkYXZlbWxvZnQubmV0PgotLS0KIGRyaXZlcnMvbmV0L3dpcmVsZXNzL2Fpcm8uYyAgICAg
ICAgICAgICAgICB8ICAgNDYgKysrKystLS0KIGRyaXZlcnMvbmV0L3dpcmVsZXNzL2F0bWVsLmMg
ICAgICAgICAgICAgICB8ICAgMjQgKysrLQogZHJpdmVycy9uZXQvd2lyZWxlc3MvaG9zdGFwL2hv
c3RhcC5oICAgICAgIHwgICAgMyAKIGRyaXZlcnMvbmV0L3dpcmVsZXNzL2hvc3RhcC9ob3N0YXBf
YXAuYyAgICB8ICAgMzIgKystLS0KIGRyaXZlcnMvbmV0L3dpcmVsZXNzL2hvc3RhcC9ob3N0YXBf
aW9jdGwuYyB8ICAgNjEgKysrKysrLS0tLQogZHJpdmVycy9uZXQvd2lyZWxlc3MvbGliZXJ0YXMv
c2Nhbi5jICAgICAgIHwgICA0MiArKysrLS0tCiBkcml2ZXJzL25ldC93aXJlbGVzcy9vcmlub2Nv
LmMgICAgICAgICAgICAgfCAgIDQxICsrKystLS0KIGRyaXZlcnMvbmV0L3dpcmVsZXNzL3ByaXNt
NTQvaXNsX2lvY3RsLmMgICB8ICAgNTUgKysrKysrLS0tCiBkcml2ZXJzL25ldC93aXJlbGVzcy93
bDM1MDFfY3MuYyAgICAgICAgICAgfCAgIDEwIC0KIGRyaXZlcnMvbmV0L3dpcmVsZXNzL3pkMTIw
MS5jICAgICAgICAgICAgICB8ICAgMjEgKystCiBpbmNsdWRlL2xpbnV4L3dpcmVsZXNzLmggICAg
ICAgICAgICAgICAgICAgfCAgIDEzICsrCiBpbmNsdWRlL25ldC9pd19oYW5kbGVyLmggICAgICAg
ICAgICAgICAgICAgfCAgMTY0ICsrKysrKysrKy0tLS0tLS0tLS0tLS0tLS0tLS0tCiBuZXQvaWVl
ZTgwMjExL2llZWU4MDIxMV93eC5jICAgICAgICAgICAgICAgfCAgIDUxICsrKysrLS0tLQogbmV0
L21hYzgwMjExL2llZWU4MDIxMV9pLmggICAgICAgICAgICAgICAgIHwgICAgNSAKIG5ldC9tYWM4
MDIxMS9pZWVlODAyMTFfaW9jdGwuYyAgICAgICAgICAgICB8ICAgIDIgCiBuZXQvbWFjODAyMTEv
aWVlZTgwMjExX3N0YS5jICAgICAgICAgICAgICAgfCAgIDU5ICsrKysrLS0tLS0KIDE2IGZpbGVz
IGNoYW5nZWQsIDM0NiBpbnNlcnRpb25zKCspLCAyODMgZGVsZXRpb25zKC0pCgotLS0gYS9kcml2
ZXJzL25ldC93aXJlbGVzcy9haXJvLmMKKysrIGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvYWlyby5j
CkBAIC03MjM0LDYgKzcyMzQsNyBAQCBvdXQ6CiAgKiBmb3JtYXQgdGhhdCB0aGUgV2lyZWxlc3Mg
VG9vbHMgd2lsbCB1bmRlcnN0YW5kIC0gSmVhbiBJSQogICovCiBzdGF0aWMgaW5saW5lIGNoYXIg
KmFpcm9fdHJhbnNsYXRlX3NjYW4oc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKKwkJCQkJc3RydWN0
IGl3X3JlcXVlc3RfaW5mbyAqaW5mbywKIAkJCQkJY2hhciAqY3VycmVudF9ldiwKIAkJCQkJY2hh
ciAqZW5kX2J1ZiwKIAkJCQkJQlNTTGlzdFJpZCAqYnNzKQpAQCAtNzI0OSw3ICs3MjUwLDggQEAg
c3RhdGljIGlubGluZSBjaGFyICphaXJvX3RyYW5zbGF0ZV9zY2FuKAogCWl3ZS5jbWQgPSBTSU9D
R0lXQVA7CiAJaXdlLnUuYXBfYWRkci5zYV9mYW1pbHkgPSBBUlBIUkRfRVRIRVI7CiAJbWVtY3B5
KGl3ZS51LmFwX2FkZHIuc2FfZGF0YSwgYnNzLT5ic3NpZCwgRVRIX0FMRU4pOwotCWN1cnJlbnRf
ZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLCBJV19F
Vl9BRERSX0xFTik7CisJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1
cnJlbnRfZXYsIGVuZF9idWYsCisJCQkJCSAgJml3ZSwgSVdfRVZfQUREUl9MRU4pOwogCiAJLyog
T3RoZXIgZW50cmllcyB3aWxsIGJlIGRpc3BsYXllZCBpbiB0aGUgb3JkZXIgd2UgZ2l2ZSB0aGVt
ICovCiAKQEAgLTcyNTksNyArNzI2MSw4IEBAIHN0YXRpYyBpbmxpbmUgY2hhciAqYWlyb190cmFu
c2xhdGVfc2NhbigKIAkJaXdlLnUuZGF0YS5sZW5ndGggPSAzMjsKIAlpd2UuY21kID0gU0lPQ0dJ
V0VTU0lEOwogCWl3ZS51LmRhdGEuZmxhZ3MgPSAxOwotCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFt
X2FkZF9wb2ludChjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLCBic3MtPnNzaWQpOworCWN1cnJl
bnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBjdXJyZW50X2V2LCBlbmRfYnVmLAor
CQkJCQkgICZpd2UsIGJzcy0+c3NpZCk7CiAKIAkvKiBBZGQgbW9kZSAqLwogCWl3ZS5jbWQgPSBT
SU9DR0lXTU9ERTsKQEAgLTcyNjksNyArNzI3Miw4IEBAIHN0YXRpYyBpbmxpbmUgY2hhciAqYWly
b190cmFuc2xhdGVfc2NhbigKIAkJCWl3ZS51Lm1vZGUgPSBJV19NT0RFX01BU1RFUjsKIAkJZWxz
ZQogCQkJaXdlLnUubW9kZSA9IElXX01PREVfQURIT0M7Ci0JCWN1cnJlbnRfZXYgPSBpd2Vfc3Ry
ZWFtX2FkZF9ldmVudChjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLCBJV19FVl9VSU5UX0xFTik7
CisJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChpbmZvLCBjdXJyZW50X2V2LCBl
bmRfYnVmLAorCQkJCQkJICAmaXdlLCBJV19FVl9VSU5UX0xFTik7CiAJfQogCiAJLyogQWRkIGZy
ZXF1ZW5jeSAqLwpAQCAtNzI4MCw3ICs3Mjg0LDggQEAgc3RhdGljIGlubGluZSBjaGFyICphaXJv
X3RyYW5zbGF0ZV9zY2FuKAogCSAqLwogCWl3ZS51LmZyZXEubSA9IGZyZXF1ZW5jeV9saXN0W2l3
ZS51LmZyZXEubSAtIDFdICogMTAwMDAwOwogCWl3ZS51LmZyZXEuZSA9IDE7Ci0JY3VycmVudF9l
diA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsIElXX0VW
X0ZSRVFfTEVOKTsKKwljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoaW5mbywgY3Vy
cmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJICAmaXdlLCBJV19FVl9GUkVRX0xFTik7CiAKIAkvKiBB
ZGQgcXVhbGl0eSBzdGF0aXN0aWNzICovCiAJaXdlLmNtZCA9IElXRVZRVUFMOwpAQCAtNzI5OCw3
ICs3MzAzLDggQEAgc3RhdGljIGlubGluZSBjaGFyICphaXJvX3RyYW5zbGF0ZV9zY2FuKAogCQkJ
CXwgSVdfUVVBTF9EQk07CiAJfQogCWl3ZS51LnF1YWwubm9pc2UgPSBhaS0+d3N0YXRzLnF1YWwu
bm9pc2U7Ci0JY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1cnJlbnRfZXYsIGVu
ZF9idWYsICZpd2UsIElXX0VWX1FVQUxfTEVOKTsKKwljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9h
ZGRfZXZlbnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJICAmaXdlLCBJV19FVl9R
VUFMX0xFTik7CiAKIAkvKiBBZGQgZW5jcnlwdGlvbiBjYXBhYmlsaXR5ICovCiAJaXdlLmNtZCA9
IFNJT0NHSVdFTkNPREU7CkBAIC03MzA3LDExICs3MzEzLDE5IEBAIHN0YXRpYyBpbmxpbmUgY2hh
ciAqYWlyb190cmFuc2xhdGVfc2NhbigKIAllbHNlCiAJCWl3ZS51LmRhdGEuZmxhZ3MgPSBJV19F
TkNPREVfRElTQUJMRUQ7CiAJaXdlLnUuZGF0YS5sZW5ndGggPSAwOwotCWN1cnJlbnRfZXYgPSBp
d2Vfc3RyZWFtX2FkZF9wb2ludChjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLCBic3MtPnNzaWQp
OworCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBjdXJyZW50X2V2LCBl
bmRfYnVmLAorCQkJCQkgICZpd2UsIGJzcy0+c3NpZCk7CiAKIAkvKiBSYXRlIDogc3R1ZmZpbmcg
bXVsdGlwbGUgdmFsdWVzIGluIGEgc2luZ2xlIGV2ZW50IHJlcXVpcmUgYSBiaXQKIAkgKiBtb3Jl
IG9mIG1hZ2ljIC0gSmVhbiBJSSAqLworI2lmZGVmIENPTkZJR19DT01QQVQKKwlpZiAoaW5mby0+
ZmxhZ3MgJiBJV19SRVFVRVNUX0ZMQUdfQ09NUEFUKQorCQljdXJyZW50X3ZhbCA9IGN1cnJlbnRf
ZXYgKyBJV19FVl9DT01QQVRfTENQX0xFTjsKKwllbHNlCisJCWN1cnJlbnRfdmFsID0gY3VycmVu
dF9ldiArIElXX0VWX0xDUF9MRU47CisjZWxzZQogCWN1cnJlbnRfdmFsID0gY3VycmVudF9ldiAr
IElXX0VWX0xDUF9MRU47CisjZW5kaWYKIAogCWl3ZS5jbWQgPSBTSU9DR0lXUkFURTsKIAkvKiBU
aG9zZSB0d28gZmxhZ3MgYXJlIGlnbm9yZWQuLi4gKi8KQEAgLTczMjQsNyArNzMzOCw5IEBAIHN0
YXRpYyBpbmxpbmUgY2hhciAqYWlyb190cmFuc2xhdGVfc2NhbigKIAkJLyogQml0IHJhdGUgZ2l2
ZW4gaW4gNTAwIGtiL3MgdW5pdHMgKCsgMHg4MCkgKi8KIAkJaXdlLnUuYml0cmF0ZS52YWx1ZSA9
ICgoYnNzLT5yYXRlc1tpXSAmIDB4N2YpICogNTAwMDAwKTsKIAkJLyogQWRkIG5ldyB2YWx1ZSB0
byBldmVudCAqLwotCQljdXJyZW50X3ZhbCA9IGl3ZV9zdHJlYW1fYWRkX3ZhbHVlKGN1cnJlbnRf
ZXYsIGN1cnJlbnRfdmFsLCBlbmRfYnVmLCAmaXdlLCBJV19FVl9QQVJBTV9MRU4pOworCQljdXJy
ZW50X3ZhbCA9IGl3ZV9zdHJlYW1fYWRkX3ZhbHVlKGluZm8sIGN1cnJlbnRfZXYsCisJCQkJCQkg
ICBjdXJyZW50X3ZhbCwgZW5kX2J1ZiwKKwkJCQkJCSAgICZpd2UsIElXX0VWX1BBUkFNX0xFTik7
CiAJfQogCS8qIENoZWNrIGlmIHdlIGFkZGVkIGFueSBldmVudCAqLwogCWlmKChjdXJyZW50X3Zh
bCAtIGN1cnJlbnRfZXYpID4gSVdfRVZfTENQX0xFTikKQEAgLTczMzYsNyArNzM1Miw4IEBAIHN0
YXRpYyBpbmxpbmUgY2hhciAqYWlyb190cmFuc2xhdGVfc2NhbigKIAkJaXdlLmNtZCA9IElXRVZD
VVNUT007CiAJCXNwcmludGYoYnVmLCAiYmNuX2ludD0lZCIsIGJzcy0+YmVhY29uSW50ZXJ2YWwp
OwogCQlpd2UudS5kYXRhLmxlbmd0aCA9IHN0cmxlbihidWYpOwotCQljdXJyZW50X2V2ID0gaXdl
X3N0cmVhbV9hZGRfcG9pbnQoY3VycmVudF9ldiwgZW5kX2J1ZiwgJml3ZSwgYnVmKTsKKwkJY3Vy
cmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIGN1cnJlbnRfZXYsIGVuZF9idWYs
CisJCQkJCQkgICZpd2UsIGJ1Zik7CiAJCWtmcmVlKGJ1Zik7CiAJfQogCkBAIC03MzcwLDggKzcz
ODcsMTAgQEAgc3RhdGljIGlubGluZSBjaGFyICphaXJvX3RyYW5zbGF0ZV9zY2FuKAogCQkJCQlp
d2UuY21kID0gSVdFVkdFTklFOwogCQkJCQlpd2UudS5kYXRhLmxlbmd0aCA9IG1pbihpbmZvX2Vs
ZW1lbnQtPmxlbiArIDIsCiAJCQkJCQkJCSAgTUFYX1dQQV9JRV9MRU4pOwotCQkJCQljdXJyZW50
X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoY3VycmVudF9ldiwgZW5kX2J1ZiwKLQkJCQkJCQkm
aXdlLCAoY2hhciAqKSBpbmZvX2VsZW1lbnQpOworCQkJCQljdXJyZW50X2V2ID0gaXdlX3N0cmVh
bV9hZGRfcG9pbnQoCisJCQkJCQkJaW5mbywgY3VycmVudF9ldiwKKwkJCQkJCQllbmRfYnVmLCAm
aXdlLAorCQkJCQkJCShjaGFyICopIGluZm9fZWxlbWVudCk7CiAJCQkJfQogCQkJCWJyZWFrOwog
CkBAIC03Mzc5LDggKzczOTgsOSBAQCBzdGF0aWMgaW5saW5lIGNoYXIgKmFpcm9fdHJhbnNsYXRl
X3NjYW4oCiAJCQkJaXdlLmNtZCA9IElXRVZHRU5JRTsKIAkJCQlpd2UudS5kYXRhLmxlbmd0aCA9
IG1pbihpbmZvX2VsZW1lbnQtPmxlbiArIDIsCiAJCQkJCQkJICBNQVhfV1BBX0lFX0xFTik7Ci0J
CQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGN1cnJlbnRfZXYsIGVuZF9idWYs
Ci0JCQkJCQkmaXdlLCAoY2hhciAqKSBpbmZvX2VsZW1lbnQpOworCQkJCWN1cnJlbnRfZXYgPSBp
d2Vfc3RyZWFtX2FkZF9wb2ludCgKKwkJCQkJaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJ
CQkJJml3ZSwgKGNoYXIgKikgaW5mb19lbGVtZW50KTsKIAkJCQlicmVhazsKIAogCQkJZGVmYXVs
dDoKQEAgLTc0MTksNyArNzQzOSw3IEBAIHN0YXRpYyBpbnQgYWlyb19nZXRfc2NhbihzdHJ1Y3Qg
bmV0X2RldmkKIAogCWxpc3RfZm9yX2VhY2hfZW50cnkgKG5ldCwgJmFpLT5uZXR3b3JrX2xpc3Qs
IGxpc3QpIHsKIAkJLyogVHJhbnNsYXRlIHRvIFdFIGZvcm1hdCB0aGlzIGVudHJ5ICovCi0JCWN1
cnJlbnRfZXYgPSBhaXJvX3RyYW5zbGF0ZV9zY2FuKGRldiwgY3VycmVudF9ldiwKKwkJY3VycmVu
dF9ldiA9IGFpcm9fdHJhbnNsYXRlX3NjYW4oZGV2LCBpbmZvLCBjdXJyZW50X2V2LAogCQkJCQkJ
IGV4dHJhICsgZHdycS0+bGVuZ3RoLAogCQkJCQkJICZuZXQtPmJzcyk7CiAKLS0tIGEvZHJpdmVy
cy9uZXQvd2lyZWxlc3MvYXRtZWwuYworKysgYi9kcml2ZXJzL25ldC93aXJlbGVzcy9hdG1lbC5j
CkBAIC0yMzIwLDMwICsyMzIwLDQwIEBAIHN0YXRpYyBpbnQgYXRtZWxfZ2V0X3NjYW4oc3RydWN0
IG5ldF9kZXYKIAkJaXdlLmNtZCA9IFNJT0NHSVdBUDsKIAkJaXdlLnUuYXBfYWRkci5zYV9mYW1p
bHkgPSBBUlBIUkRfRVRIRVI7CiAJCW1lbWNweShpd2UudS5hcF9hZGRyLnNhX2RhdGEsIHByaXYt
PkJTU2luZm9baV0uQlNTSUQsIDYpOwotCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZl
bnQoY3VycmVudF9ldiwgZXh0cmEgKyBJV19TQ0FOX01BWF9EQVRBLCAmaXdlLCBJV19FVl9BRERS
X0xFTik7CisJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChpbmZvLCBjdXJyZW50
X2V2LAorCQkJCQkJICBleHRyYSArIElXX1NDQU5fTUFYX0RBVEEsCisJCQkJCQkgICZpd2UsIElX
X0VWX0FERFJfTEVOKTsKIAogCQlpd2UudS5kYXRhLmxlbmd0aCA9ICBwcml2LT5CU1NpbmZvW2ld
LlNTSURzaXplOwogCQlpZiAoaXdlLnUuZGF0YS5sZW5ndGggPiAzMikKIAkJCWl3ZS51LmRhdGEu
bGVuZ3RoID0gMzI7CiAJCWl3ZS5jbWQgPSBTSU9DR0lXRVNTSUQ7CiAJCWl3ZS51LmRhdGEuZmxh
Z3MgPSAxOwotCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoY3VycmVudF9ldiwg
ZXh0cmEgKyBJV19TQ0FOX01BWF9EQVRBLCAmaXdlLCBwcml2LT5CU1NpbmZvW2ldLlNTSUQpOwor
CQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoaW5mbywgY3VycmVudF9ldiwKKwkJ
CQkJCSAgZXh0cmEgKyBJV19TQ0FOX01BWF9EQVRBLAorCQkJCQkJICAmaXdlLCBwcml2LT5CU1Np
bmZvW2ldLlNTSUQpOwogCiAJCWl3ZS5jbWQgPSBTSU9DR0lXTU9ERTsKIAkJaXdlLnUubW9kZSA9
IHByaXYtPkJTU2luZm9baV0uQlNTdHlwZTsKLQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRk
X2V2ZW50KGN1cnJlbnRfZXYsIGV4dHJhICsgSVdfU0NBTl9NQVhfREFUQSwgJml3ZSwgSVdfRVZf
VUlOVF9MRU4pOworCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoaW5mbywgY3Vy
cmVudF9ldiwKKwkJCQkJCSAgZXh0cmEgKyBJV19TQ0FOX01BWF9EQVRBLAorCQkJCQkJICAmaXdl
LCBJV19FVl9VSU5UX0xFTik7CiAKIAkJaXdlLmNtZCA9IFNJT0NHSVdGUkVROwogCQlpd2UudS5m
cmVxLm0gPSBwcml2LT5CU1NpbmZvW2ldLmNoYW5uZWw7CiAJCWl3ZS51LmZyZXEuZSA9IDA7Ci0J
CWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChjdXJyZW50X2V2LCBleHRyYSArIElX
X1NDQU5fTUFYX0RBVEEsICZpd2UsIElXX0VWX0ZSRVFfTEVOKTsKKwkJY3VycmVudF9ldiA9IGl3
ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1cnJlbnRfZXYsCisJCQkJCQkgIGV4dHJhICsgSVdf
U0NBTl9NQVhfREFUQSwKKwkJCQkJCSAgJml3ZSwgSVdfRVZfRlJFUV9MRU4pOwogCiAJCS8qIEFk
ZCBxdWFsaXR5IHN0YXRpc3RpY3MgKi8KIAkJaXdlLmNtZCA9IElXRVZRVUFMOwogCQlpd2UudS5x
dWFsLmxldmVsID0gcHJpdi0+QlNTaW5mb1tpXS5SU1NJOwogCQlpd2UudS5xdWFsLnF1YWwgID0g
aXdlLnUucXVhbC5sZXZlbDsKIAkJLyogaXdlLnUucXVhbC5ub2lzZSAgPSBTT01FVEhJTkcgKi8K
LQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1cnJlbnRfZXYsIGV4dHJhICsg
SVdfU0NBTl9NQVhfREFUQSAsICZpd2UsIElXX0VWX1FVQUxfTEVOKTsKKwkJY3VycmVudF9ldiA9
IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1cnJlbnRfZXYsCisJCQkJCQkgIGV4dHJhICsg
SVdfU0NBTl9NQVhfREFUQSwKKwkJCQkJCSAgJml3ZSwgSVdfRVZfUVVBTF9MRU4pOwogCiAKIAkJ
aXdlLmNtZCA9IFNJT0NHSVdFTkNPREU7CkBAIC0yMzUyLDcgKzIzNjIsOSBAQCBzdGF0aWMgaW50
IGF0bWVsX2dldF9zY2FuKHN0cnVjdCBuZXRfZGV2CiAJCWVsc2UKIAkJCWl3ZS51LmRhdGEuZmxh
Z3MgPSBJV19FTkNPREVfRElTQUJMRUQ7CiAJCWl3ZS51LmRhdGEubGVuZ3RoID0gMDsKLQkJY3Vy
cmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGN1cnJlbnRfZXYsIGV4dHJhICsgSVdfU0NB
Tl9NQVhfREFUQSwgJml3ZSwgTlVMTCk7CisJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9w
b2ludChpbmZvLCBjdXJyZW50X2V2LAorCQkJCQkJICBleHRyYSArIElXX1NDQU5fTUFYX0RBVEEs
CisJCQkJCQkgICZpd2UsIE5VTEwpOwogCX0KIAogCS8qIExlbmd0aCBvZiBkYXRhICovCi0tLSBh
L2RyaXZlcnMvbmV0L3dpcmVsZXNzL2hvc3RhcC9ob3N0YXAuaAorKysgYi9kcml2ZXJzL25ldC93
aXJlbGVzcy9ob3N0YXAvaG9zdGFwLmgKQEAgLTY3LDcgKzY3LDggQEAgdm9pZCAqIGFwX2NyeXB0
X2dldF9wdHJzKHN0cnVjdCBhcF9kYXRhIAogaW50IHByaXNtMl9hcF9nZXRfc3RhX3F1YWwobG9j
YWxfaW5mb190ICpsb2NhbCwgc3RydWN0IHNvY2thZGRyIGFkZHJbXSwKIAkJCSAgIHN0cnVjdCBp
d19xdWFsaXR5IHF1YWxbXSwgaW50IGJ1Zl9zaXplLAogCQkJICAgaW50IGFwbGlzdCk7Ci1pbnQg
cHJpc20yX2FwX3RyYW5zbGF0ZV9zY2FuKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIGNoYXIgKmJ1
ZmZlcik7CitpbnQgcHJpc20yX2FwX3RyYW5zbGF0ZV9zY2FuKHN0cnVjdCBuZXRfZGV2aWNlICpk
ZXYsCisJCQkgICAgIHN0cnVjdCBpd19yZXF1ZXN0X2luZm8gKmluZm8sIGNoYXIgKmJ1ZmZlcik7
CiBpbnQgcHJpc20yX2hvc3RhcGQoc3RydWN0IGFwX2RhdGEgKmFwLCBzdHJ1Y3QgcHJpc20yX2hv
c3RhcGRfcGFyYW0gKnBhcmFtKTsKIAogCi0tLSBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2hvc3Rh
cC9ob3N0YXBfYXAuYworKysgYi9kcml2ZXJzL25ldC93aXJlbGVzcy9ob3N0YXAvaG9zdGFwX2Fw
LmMKQEAgLTIzODEsNyArMjM4MSw4IEBAIGludCBwcmlzbTJfYXBfZ2V0X3N0YV9xdWFsKGxvY2Fs
X2luZm9fdCAKIAogLyogVHJhbnNsYXRlIG91ciBsaXN0IG9mIEFjY2VzcyBQb2ludHMgJiBTdGF0
aW9ucyB0byBhIGNhcmQgaW5kZXBlbmRhbnQKICAqIGZvcm1hdCB0aGF0IHRoZSBXaXJlbGVzcyBU
b29scyB3aWxsIHVuZGVyc3RhbmQgLSBKZWFuIElJICovCi1pbnQgcHJpc20yX2FwX3RyYW5zbGF0
ZV9zY2FuKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIGNoYXIgKmJ1ZmZlcikKK2ludCBwcmlzbTJf
YXBfdHJhbnNsYXRlX3NjYW4oc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKKwkJCSAgICAgc3RydWN0
IGl3X3JlcXVlc3RfaW5mbyAqaW5mbywgY2hhciAqYnVmZmVyKQogewogCXN0cnVjdCBob3N0YXBf
aW50ZXJmYWNlICppZmFjZTsKIAlsb2NhbF9pbmZvX3QgKmxvY2FsOwpAQCAtMjQxMCw4ICsyNDEx
LDggQEAgaW50IHByaXNtMl9hcF90cmFuc2xhdGVfc2NhbihzdHJ1Y3QgbmV0XwogCQlpd2UudS5h
cF9hZGRyLnNhX2ZhbWlseSA9IEFSUEhSRF9FVEhFUjsKIAkJbWVtY3B5KGl3ZS51LmFwX2FkZHIu
c2FfZGF0YSwgc3RhLT5hZGRyLCBFVEhfQUxFTik7CiAJCWl3ZS5sZW4gPSBJV19FVl9BRERSX0xF
TjsKLQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1cnJlbnRfZXYsIGVuZF9i
dWYsICZpd2UsCi0JCQkJCQkgIElXX0VWX0FERFJfTEVOKTsKKwkJY3VycmVudF9ldiA9IGl3ZV9z
dHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1cnJlbnRfZXYsIGVuZF9idWYsCisJCQkJCQkgICZpd2Us
IElXX0VWX0FERFJfTEVOKTsKIAogCQkvKiBVc2UgdGhlIG1vZGUgdG8gaW5kaWNhdGUgaWYgaXQn
cyBhIHN0YXRpb24gb3IKIAkJICogYW4gQWNjZXNzIFBvaW50ICovCkBAIC0yNDIyLDggKzI0MjMs
OCBAQCBpbnQgcHJpc20yX2FwX3RyYW5zbGF0ZV9zY2FuKHN0cnVjdCBuZXRfCiAJCWVsc2UKIAkJ
CWl3ZS51Lm1vZGUgPSBJV19NT0RFX0lORlJBOwogCQlpd2UubGVuID0gSVdfRVZfVUlOVF9MRU47
Ci0JCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChjdXJyZW50X2V2LCBlbmRfYnVm
LCAmaXdlLAotCQkJCQkJICBJV19FVl9VSU5UX0xFTik7CisJCWN1cnJlbnRfZXYgPSBpd2Vfc3Ry
ZWFtX2FkZF9ldmVudChpbmZvLCBjdXJyZW50X2V2LCBlbmRfYnVmLAorCQkJCQkJICAmaXdlLCBJ
V19FVl9VSU5UX0xFTik7CiAKIAkJLyogU29tZSBxdWFsaXR5ICovCiAJCW1lbXNldCgmaXdlLCAw
LCBzaXplb2YoaXdlKSk7CkBAIC0yNDM4LDggKzI0MzksOCBAQCBpbnQgcHJpc20yX2FwX3RyYW5z
bGF0ZV9zY2FuKHN0cnVjdCBuZXRfCiAJCWl3ZS51LnF1YWwubm9pc2UgPSBIRkEzODRYX0xFVkVM
X1RPX2RCbShzdGEtPmxhc3Rfcnhfc2lsZW5jZSk7CiAJCWl3ZS51LnF1YWwudXBkYXRlZCA9IHN0
YS0+bGFzdF9yeF91cGRhdGVkOwogCQlpd2UubGVuID0gSVdfRVZfUVVBTF9MRU47Ci0JCWN1cnJl
bnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLAot
CQkJCQkJICBJV19FVl9RVUFMX0xFTik7CisJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9l
dmVudChpbmZvLCBjdXJyZW50X2V2LCBlbmRfYnVmLAorCQkJCQkJICAmaXdlLCBJV19FVl9RVUFM
X0xFTik7CiAKICNpZm5kZWYgUFJJU00yX05PX0tFUk5FTF9JRUVFODAyMTFfTUdNVAogCQlpZiAo
c3RhLT5hcCkgewpAQCAtMjQ0Nyw4ICsyNDQ4LDggQEAgaW50IHByaXNtMl9hcF90cmFuc2xhdGVf
c2NhbihzdHJ1Y3QgbmV0XwogCQkJaXdlLmNtZCA9IFNJT0NHSVdFU1NJRDsKIAkJCWl3ZS51LmRh
dGEubGVuZ3RoID0gc3RhLT51LmFwLnNzaWRfbGVuOwogCQkJaXdlLnUuZGF0YS5mbGFncyA9IDE7
Ci0JCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoY3VycmVudF9ldiwgZW5kX2J1
ZiwKLQkJCQkJCQkgICZpd2UsCisJCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQo
aW5mbywgY3VycmVudF9ldiwKKwkJCQkJCQkgIGVuZF9idWYsICZpd2UsCiAJCQkJCQkJICBzdGEt
PnUuYXAuc3NpZCk7CiAKIAkJCW1lbXNldCgmaXdlLCAwLCBzaXplb2YoaXdlKSk7CkBAIC0yNDU4
LDEwICsyNDU5LDkgQEAgaW50IHByaXNtMl9hcF90cmFuc2xhdGVfc2NhbihzdHJ1Y3QgbmV0Xwog
CQkJCQlJV19FTkNPREVfRU5BQkxFRCB8IElXX0VOQ09ERV9OT0tFWTsKIAkJCWVsc2UKIAkJCQlp
d2UudS5kYXRhLmZsYWdzID0gSVdfRU5DT0RFX0RJU0FCTEVEOwotCQkJY3VycmVudF9ldiA9IGl3
ZV9zdHJlYW1fYWRkX3BvaW50KGN1cnJlbnRfZXYsIGVuZF9idWYsCi0JCQkJCQkJICAmaXdlLAot
CQkJCQkJCSAgc3RhLT51LmFwLnNzaWQKLQkJCQkJCQkgIC8qIDAgYnl0ZSBtZW1jcHkgKi8pOwor
CQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIGN1cnJlbnRfZXYsCisJ
CQkJCQkJICBlbmRfYnVmLCAmaXdlLAorCQkJCQkJCSAgc3RhLT51LmFwLnNzaWQpOwogCiAJCQlp
ZiAoc3RhLT51LmFwLmNoYW5uZWwgPiAwICYmCiAJCQkgICAgc3RhLT51LmFwLmNoYW5uZWwgPD0g
RlJFUV9DT1VOVCkgewpAQCAtMjQ3MSw3ICsyNDcxLDcgQEAgaW50IHByaXNtMl9hcF90cmFuc2xh
dGVfc2NhbihzdHJ1Y3QgbmV0XwogCQkJCQkqIDEwMDAwMDsKIAkJCQlpd2UudS5mcmVxLmUgPSAx
OwogCQkJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudCgKLQkJCQkJY3VycmVudF9l
diwgZW5kX2J1ZiwgJml3ZSwKKwkJCQkJaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwgJml3ZSwK
IAkJCQkJSVdfRVZfRlJFUV9MRU4pOwogCQkJfQogCkBAIC0yNDgwLDggKzI0ODAsOCBAQCBpbnQg
cHJpc20yX2FwX3RyYW5zbGF0ZV9zY2FuKHN0cnVjdCBuZXRfCiAJCQlzcHJpbnRmKGJ1ZiwgImJl
YWNvbl9pbnRlcnZhbD0lZCIsCiAJCQkJc3RhLT5saXN0ZW5faW50ZXJ2YWwpOwogCQkJaXdlLnUu
ZGF0YS5sZW5ndGggPSBzdHJsZW4oYnVmKTsKLQkJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2Fk
ZF9wb2ludChjdXJyZW50X2V2LCBlbmRfYnVmLAotCQkJCQkJCSAgJml3ZSwgYnVmKTsKKwkJCWN1
cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBjdXJyZW50X2V2LAorCQkJCQkJ
CSAgZW5kX2J1ZiwgJml3ZSwgYnVmKTsKIAkJfQogI2VuZGlmIC8qIFBSSVNNMl9OT19LRVJORUxf
SUVFRTgwMjExX01HTVQgKi8KIAotLS0gYS9kcml2ZXJzL25ldC93aXJlbGVzcy9ob3N0YXAvaG9z
dGFwX2lvY3RsLmMKKysrIGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvaG9zdGFwL2hvc3RhcF9pb2N0
bC5jCkBAIC0xNzk0LDYgKzE3OTQsNyBAQCBzdGF0aWMgaW50IHByaXNtMl9pb2N0bF9zaXdzY2Fu
KHN0cnVjdCBuCiAKICNpZm5kZWYgUFJJU00yX05PX1NUQVRJT05fTU9ERVMKIHN0YXRpYyBjaGFy
ICogX19wcmlzbTJfdHJhbnNsYXRlX3NjYW4obG9jYWxfaW5mb190ICpsb2NhbCwKKwkJCQkgICAg
ICBzdHJ1Y3QgaXdfcmVxdWVzdF9pbmZvICppbmZvLAogCQkJCSAgICAgIHN0cnVjdCBoZmEzODR4
X2hvc3RzY2FuX3Jlc3VsdCAqc2NhbiwKIAkJCQkgICAgICBzdHJ1Y3QgaG9zdGFwX2Jzc19pbmZv
ICpic3MsCiAJCQkJICAgICAgY2hhciAqY3VycmVudF9ldiwgY2hhciAqZW5kX2J1ZikKQEAgLTE4
MjQsNyArMTgyNSw3IEBAIHN0YXRpYyBjaGFyICogX19wcmlzbTJfdHJhbnNsYXRlX3NjYW4obG8K
IAlpd2UuY21kID0gU0lPQ0dJV0FQOwogCWl3ZS51LmFwX2FkZHIuc2FfZmFtaWx5ID0gQVJQSFJE
X0VUSEVSOwogCW1lbWNweShpd2UudS5hcF9hZGRyLnNhX2RhdGEsIGJzc2lkLCBFVEhfQUxFTik7
Ci0JY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1cnJlbnRfZXYsIGVuZF9idWYs
ICZpd2UsCisJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1cnJlbnRf
ZXYsIGVuZF9idWYsICZpd2UsCiAJCQkJCSAgSVdfRVZfQUREUl9MRU4pOwogCiAJLyogT3RoZXIg
ZW50cmllcyB3aWxsIGJlIGRpc3BsYXllZCBpbiB0aGUgb3JkZXIgd2UgZ2l2ZSB0aGVtICovCkBA
IC0xODMzLDcgKzE4MzQsOCBAQCBzdGF0aWMgY2hhciAqIF9fcHJpc20yX3RyYW5zbGF0ZV9zY2Fu
KGxvCiAJaXdlLmNtZCA9IFNJT0NHSVdFU1NJRDsKIAlpd2UudS5kYXRhLmxlbmd0aCA9IHNzaWRf
bGVuOwogCWl3ZS51LmRhdGEuZmxhZ3MgPSAxOwotCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2Fk
ZF9wb2ludChjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLCBzc2lkKTsKKwljdXJyZW50X2V2ID0g
aXdlX3N0cmVhbV9hZGRfcG9pbnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJICAm
aXdlLCBzc2lkKTsKIAogCW1lbXNldCgmaXdlLCAwLCBzaXplb2YoaXdlKSk7CiAJaXdlLmNtZCA9
IFNJT0NHSVdNT0RFOwpAQCAtMTg0OCw4ICsxODUwLDggQEAgc3RhdGljIGNoYXIgKiBfX3ByaXNt
Ml90cmFuc2xhdGVfc2NhbihsbwogCQkJaXdlLnUubW9kZSA9IElXX01PREVfTUFTVEVSOwogCQll
bHNlCiAJCQlpd2UudS5tb2RlID0gSVdfTU9ERV9BREhPQzsKLQkJY3VycmVudF9ldiA9IGl3ZV9z
dHJlYW1fYWRkX2V2ZW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsCi0JCQkJCQkgIElXX0VW
X1VJTlRfTEVOKTsKKwkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1
cnJlbnRfZXYsIGVuZF9idWYsCisJCQkJCQkgICZpd2UsIElXX0VWX1VJTlRfTEVOKTsKIAl9CiAK
IAltZW1zZXQoJml3ZSwgMCwgc2l6ZW9mKGl3ZSkpOwpAQCAtMTg2NSw4ICsxODY3LDggQEAgc3Rh
dGljIGNoYXIgKiBfX3ByaXNtMl90cmFuc2xhdGVfc2NhbihsbwogCWlmIChjaGFuID4gMCkgewog
CQlpd2UudS5mcmVxLm0gPSBmcmVxX2xpc3RbY2hhbiAtIDFdICogMTAwMDAwOwogCQlpd2UudS5m
cmVxLmUgPSAxOwotCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoY3VycmVudF9l
diwgZW5kX2J1ZiwgJml3ZSwKLQkJCQkJCSAgSVdfRVZfRlJFUV9MRU4pOworCQljdXJyZW50X2V2
ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJ
CSAgJml3ZSwgSVdfRVZfRlJFUV9MRU4pOwogCX0KIAogCWlmIChzY2FuKSB7CkBAIC0xODg1LDgg
KzE4ODcsOCBAQCBzdGF0aWMgY2hhciAqIF9fcHJpc20yX3RyYW5zbGF0ZV9zY2FuKGxvCiAJCQl8
IElXX1FVQUxfTk9JU0VfVVBEQVRFRAogCQkJfCBJV19RVUFMX1FVQUxfSU5WQUxJRAogCQkJfCBJ
V19RVUFMX0RCTTsKLQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1cnJlbnRf
ZXYsIGVuZF9idWYsICZpd2UsCi0JCQkJCQkgIElXX0VWX1FVQUxfTEVOKTsKKwkJY3VycmVudF9l
diA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1cnJlbnRfZXYsIGVuZF9idWYsCisJCQkJ
CQkgICZpd2UsIElXX0VWX1FVQUxfTEVOKTsKIAl9CiAKIAltZW1zZXQoJml3ZSwgMCwgc2l6ZW9m
KGl3ZSkpOwpAQCAtMTg5NiwxMyArMTg5OCwyMCBAQCBzdGF0aWMgY2hhciAqIF9fcHJpc20yX3Ry
YW5zbGF0ZV9zY2FuKGxvCiAJZWxzZQogCQlpd2UudS5kYXRhLmZsYWdzID0gSVdfRU5DT0RFX0RJ
U0FCTEVEOwogCWl3ZS51LmRhdGEubGVuZ3RoID0gMDsKLQljdXJyZW50X2V2ID0gaXdlX3N0cmVh
bV9hZGRfcG9pbnQoY3VycmVudF9ldiwgZW5kX2J1ZiwgJml3ZSwgIiIpOworCWN1cnJlbnRfZXYg
PSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLCAi
Iik7CiAKIAkvKiBUT0RPOiBhZGQgU3VwcFJhdGVzIGludG8gQlNTIHRhYmxlICovCiAJaWYgKHNj
YW4pIHsKIAkJbWVtc2V0KCZpd2UsIDAsIHNpemVvZihpd2UpKTsKIAkJaXdlLmNtZCA9IFNJT0NH
SVdSQVRFOworI2lmZGVmIENPTkZJR19DT01QQVQKKwkJaWYgKGluZm8tPmZsYWdzICYgSVdfUkVR
VUVTVF9GTEFHX0NPTVBBVCkKKwkJCWN1cnJlbnRfdmFsID0gY3VycmVudF9ldiArIElXX0VWX0NP
TVBBVF9MQ1BfTEVOOworCQllbHNlCisJCQljdXJyZW50X3ZhbCA9IGN1cnJlbnRfZXYgKyBJV19F
Vl9MQ1BfTEVOOworI2Vsc2UKIAkJY3VycmVudF92YWwgPSBjdXJyZW50X2V2ICsgSVdfRVZfTENQ
X0xFTjsKKyNlbmRpZgogCQlwb3MgPSBzY2FuLT5zdXBfcmF0ZXM7CiAJCWZvciAoaSA9IDA7IGkg
PCBzaXplb2Yoc2Nhbi0+c3VwX3JhdGVzKTsgaSsrKSB7CiAJCQlpZiAocG9zW2ldID09IDApCkBA
IC0xOTEwLDcgKzE5MTksNyBAQCBzdGF0aWMgY2hhciAqIF9fcHJpc20yX3RyYW5zbGF0ZV9zY2Fu
KGxvCiAJCQkvKiBCaXQgcmF0ZSBnaXZlbiBpbiA1MDAga2IvcyB1bml0cyAoKyAweDgwKSAqLwog
CQkJaXdlLnUuYml0cmF0ZS52YWx1ZSA9ICgocG9zW2ldICYgMHg3ZikgKiA1MDAwMDApOwogCQkJ
Y3VycmVudF92YWwgPSBpd2Vfc3RyZWFtX2FkZF92YWx1ZSgKLQkJCQljdXJyZW50X2V2LCBjdXJy
ZW50X3ZhbCwgZW5kX2J1ZiwgJml3ZSwKKwkJCQlpbmZvLCBjdXJyZW50X2V2LCBjdXJyZW50X3Zh
bCwgZW5kX2J1ZiwgJml3ZSwKIAkJCQlJV19FVl9QQVJBTV9MRU4pOwogCQl9CiAJCS8qIENoZWNr
IGlmIHdlIGFkZGVkIGFueSBldmVudCAqLwpAQCAtMTkyNSwxNSArMTkzNCwxNSBAQCBzdGF0aWMg
Y2hhciAqIF9fcHJpc20yX3RyYW5zbGF0ZV9zY2FuKGxvCiAJCWl3ZS5jbWQgPSBJV0VWQ1VTVE9N
OwogCQlzcHJpbnRmKGJ1ZiwgImJjbl9pbnQ9JWQiLCBsZTE2X3RvX2NwdShzY2FuLT5iZWFjb25f
aW50ZXJ2YWwpKTsKIAkJaXdlLnUuZGF0YS5sZW5ndGggPSBzdHJsZW4oYnVmKTsKLQkJY3VycmVu
dF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsCi0J
CQkJCQkgIGJ1Zik7CisJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBj
dXJyZW50X2V2LCBlbmRfYnVmLAorCQkJCQkJICAmaXdlLCBidWYpOwogCiAJCW1lbXNldCgmaXdl
LCAwLCBzaXplb2YoaXdlKSk7CiAJCWl3ZS5jbWQgPSBJV0VWQ1VTVE9NOwogCQlzcHJpbnRmKGJ1
ZiwgInJlc3BfcmF0ZT0lZCIsIGxlMTZfdG9fY3B1KHNjYW4tPnJhdGUpKTsKIAkJaXdlLnUuZGF0
YS5sZW5ndGggPSBzdHJsZW4oYnVmKTsKLQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3Bv
aW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsCi0JCQkJCQkgIGJ1Zik7CisJCWN1cnJlbnRf
ZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBjdXJyZW50X2V2LCBlbmRfYnVmLAorCQkJ
CQkJICAmaXdlLCBidWYpOwogCiAJCWlmIChsb2NhbC0+bGFzdF9zY2FuX3R5cGUgPT0gUFJJU00y
X0hPU1RTQ0FOICYmCiAJCSAgICAoY2FwYWJpbGl0aWVzICYgV0xBTl9DQVBBQklMSVRZX0lCU1Mp
KSB7CkBAIC0xOTQxLDggKzE5NTAsOCBAQCBzdGF0aWMgY2hhciAqIF9fcHJpc20yX3RyYW5zbGF0
ZV9zY2FuKGxvCiAJCQlpd2UuY21kID0gSVdFVkNVU1RPTTsKIAkJCXNwcmludGYoYnVmLCAiYXRp
bT0lZCIsIGxlMTZfdG9fY3B1KHNjYW4tPmF0aW0pKTsKIAkJCWl3ZS51LmRhdGEubGVuZ3RoID0g
c3RybGVuKGJ1Zik7Ci0JCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoY3VycmVu
dF9ldiwgZW5kX2J1ZiwKLQkJCQkJCQkgICZpd2UsIGJ1Zik7CisJCQljdXJyZW50X2V2ID0gaXdl
X3N0cmVhbV9hZGRfcG9pbnQoaW5mbywgY3VycmVudF9ldiwKKwkJCQkJCQkgIGVuZF9idWYsICZp
d2UsIGJ1Zik7CiAJCX0KIAl9CiAJa2ZyZWUoYnVmKTsKQEAgLTE5NTEsMTYgKzE5NjAsMTYgQEAg
c3RhdGljIGNoYXIgKiBfX3ByaXNtMl90cmFuc2xhdGVfc2NhbihsbwogCQltZW1zZXQoJml3ZSwg
MCwgc2l6ZW9mKGl3ZSkpOwogCQlpd2UuY21kID0gSVdFVkdFTklFOwogCQlpd2UudS5kYXRhLmxl
bmd0aCA9IGJzcy0+d3BhX2llX2xlbjsKLQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3Bv
aW50KAotCQkJY3VycmVudF9ldiwgZW5kX2J1ZiwgJml3ZSwgYnNzLT53cGFfaWUpOworCQljdXJy
ZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwK
KwkJCQkJCSAgJml3ZSwgYnNzLT53cGFfaWUpOwogCX0KIAogCWlmIChic3MgJiYgYnNzLT5yc25f
aWVfbGVuID4gMCAmJiBic3MtPnJzbl9pZV9sZW4gPD0gTUFYX1dQQV9JRV9MRU4pIHsKIAkJbWVt
c2V0KCZpd2UsIDAsIHNpemVvZihpd2UpKTsKIAkJaXdlLmNtZCA9IElXRVZHRU5JRTsKIAkJaXdl
LnUuZGF0YS5sZW5ndGggPSBic3MtPnJzbl9pZV9sZW47Ci0JCWN1cnJlbnRfZXYgPSBpd2Vfc3Ry
ZWFtX2FkZF9wb2ludCgKLQkJCWN1cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsIGJzcy0+cnNuX2ll
KTsKKwkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIGN1cnJlbnRfZXYs
IGVuZF9idWYsCisJCQkJCQkgICZpd2UsIGJzcy0+cnNuX2llKTsKIAl9CiAKIAlyZXR1cm4gY3Vy
cmVudF9ldjsKQEAgLTE5NzAsNiArMTk3OSw3IEBAIHN0YXRpYyBjaGFyICogX19wcmlzbTJfdHJh
bnNsYXRlX3NjYW4obG8KIC8qIFRyYW5zbGF0ZSBzY2FuIGRhdGEgcmV0dXJuZWQgZnJvbSB0aGUg
Y2FyZCB0byBhIGNhcmQgaW5kZXBlbmRhbnQKICAqIGZvcm1hdCB0aGF0IHRoZSBXaXJlbGVzcyBU
b29scyB3aWxsIHVuZGVyc3RhbmQgLSBKZWFuIElJICovCiBzdGF0aWMgaW5saW5lIGludCBwcmlz
bTJfdHJhbnNsYXRlX3NjYW4obG9jYWxfaW5mb190ICpsb2NhbCwKKwkJCQkJc3RydWN0IGl3X3Jl
cXVlc3RfaW5mbyAqaW5mbywKIAkJCQkJY2hhciAqYnVmZmVyLCBpbnQgYnVmbGVuKQogewogCXN0
cnVjdCBoZmEzODR4X2hvc3RzY2FuX3Jlc3VsdCAqc2NhbjsKQEAgLTIwMDAsMTMgKzIwMTAsMTQg
QEAgc3RhdGljIGlubGluZSBpbnQgcHJpc20yX3RyYW5zbGF0ZV9zY2FuKAogCQkJaWYgKG1lbWNt
cChic3MtPmJzc2lkLCBzY2FuLT5ic3NpZCwgRVRIX0FMRU4pID09IDApIHsKIAkJCQlic3MtPmlu
Y2x1ZGVkID0gMTsKIAkJCQljdXJyZW50X2V2ID0gX19wcmlzbTJfdHJhbnNsYXRlX3NjYW4oCi0J
CQkJCWxvY2FsLCBzY2FuLCBic3MsIGN1cnJlbnRfZXYsIGVuZF9idWYpOworCQkJCQlsb2NhbCwg
aW5mbywgc2NhbiwgYnNzLCBjdXJyZW50X2V2LAorCQkJCQllbmRfYnVmKTsKIAkJCQlmb3VuZCsr
OwogCQkJfQogCQl9CiAJCWlmICghZm91bmQpIHsKIAkJCWN1cnJlbnRfZXYgPSBfX3ByaXNtMl90
cmFuc2xhdGVfc2NhbigKLQkJCQlsb2NhbCwgc2NhbiwgTlVMTCwgY3VycmVudF9ldiwgZW5kX2J1
Zik7CisJCQkJbG9jYWwsIGluZm8sIHNjYW4sIE5VTEwsIGN1cnJlbnRfZXYsIGVuZF9idWYpOwog
CQl9CiAJCS8qIENoZWNrIGlmIHRoZXJlIGlzIHNwYWNlIGZvciBvbmUgbW9yZSBlbnRyeSAqLwog
CQlpZiAoKGVuZF9idWYgLSBjdXJyZW50X2V2KSA8PSBJV19FVl9BRERSX0xFTikgewpAQCAtMjAy
NCw3ICsyMDM1LDcgQEAgc3RhdGljIGlubGluZSBpbnQgcHJpc20yX3RyYW5zbGF0ZV9zY2FuKAog
CQlic3MgPSBsaXN0X2VudHJ5KHB0ciwgc3RydWN0IGhvc3RhcF9ic3NfaW5mbywgbGlzdCk7CiAJ
CWlmIChic3MtPmluY2x1ZGVkKQogCQkJY29udGludWU7Ci0JCWN1cnJlbnRfZXYgPSBfX3ByaXNt
Ml90cmFuc2xhdGVfc2Nhbihsb2NhbCwgTlVMTCwgYnNzLAorCQljdXJyZW50X2V2ID0gX19wcmlz
bTJfdHJhbnNsYXRlX3NjYW4obG9jYWwsIGluZm8sIE5VTEwsIGJzcywKIAkJCQkJCSAgICAgY3Vy
cmVudF9ldiwgZW5kX2J1Zik7CiAJCS8qIENoZWNrIGlmIHRoZXJlIGlzIHNwYWNlIGZvciBvbmUg
bW9yZSBlbnRyeSAqLwogCQlpZiAoKGVuZF9idWYgLSBjdXJyZW50X2V2KSA8PSBJV19FVl9BRERS
X0xFTikgewpAQCAtMjA3MSw3ICsyMDgyLDcgQEAgc3RhdGljIGlubGluZSBpbnQgcHJpc20yX2lv
Y3RsX2dpd3NjYW5fcwogCX0KIAlsb2NhbC0+c2Nhbl90aW1lc3RhbXAgPSAwOwogCi0JcmVzID0g
cHJpc20yX3RyYW5zbGF0ZV9zY2FuKGxvY2FsLCBleHRyYSwgZGF0YS0+bGVuZ3RoKTsKKwlyZXMg
PSBwcmlzbTJfdHJhbnNsYXRlX3NjYW4obG9jYWwsIGluZm8sIGV4dHJhLCBkYXRhLT5sZW5ndGgp
OwogCiAJaWYgKHJlcyA+PSAwKSB7CiAJCWRhdGEtPmxlbmd0aCA9IHJlczsKQEAgLTIxMDQsNyAr
MjExNSw3IEBAIHN0YXRpYyBpbnQgcHJpc20yX2lvY3RsX2dpd3NjYW4oc3RydWN0IG4KIAkJICog
SmVhbiBJSSAqLwogCiAJCS8qIFRyYW5zbGF0ZSB0byBXRSBmb3JtYXQgKi8KLQkJcmVzID0gcHJp
c20yX2FwX3RyYW5zbGF0ZV9zY2FuKGRldiwgZXh0cmEpOworCQlyZXMgPSBwcmlzbTJfYXBfdHJh
bnNsYXRlX3NjYW4oZGV2LCBpbmZvLCBleHRyYSk7CiAJCWlmIChyZXMgPj0gMCkgewogCQkJcHJp
bnRrKEtFUk5fREVCVUcgIlNjYW4gcmVzdWx0IHRyYW5zbGF0aW9uIHN1Y2NlZWRlZCAiCiAJCQkg
ICAgICAgIihsZW5ndGg9JWQpXG4iLCByZXMpOwotLS0gYS9kcml2ZXJzL25ldC93aXJlbGVzcy9s
aWJlcnRhcy9zY2FuLmMKKysrIGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvbGliZXJ0YXMvc2Nhbi5j
CkBAIC0xNDQ0LDggKzE0NDQsOSBAQCBvdXQ6CiAjZGVmaW5lIE1BWF9DVVNUT01fTEVOIDY0CiAK
IHN0YXRpYyBpbmxpbmUgY2hhciAqbGliZXJ0YXNfdHJhbnNsYXRlX3NjYW4od2xhbl9wcml2YXRl
ICpwcml2LAotCQkJCQljaGFyICpzdGFydCwgY2hhciAqc3RvcCwKLQkJCQkJc3RydWN0IGJzc19k
ZXNjcmlwdG9yICpic3MpCisJCQkJCSAgICBzdHJ1Y3QgaXdfcmVxdWVzdF9pbmZvICppbmZvLAor
CQkJCQkgICAgY2hhciAqc3RhcnQsIGNoYXIgKnN0b3AsCisJCQkJCSAgICBzdHJ1Y3QgYnNzX2Rl
c2NyaXB0b3IgKmJzcykKIHsKIAl3bGFuX2FkYXB0ZXIgKmFkYXB0ZXIgPSBwcml2LT5hZGFwdGVy
OwogCXN0cnVjdCBjaGFuX2ZyZXFfcG93ZXIgKmNmcDsKQEAgLTE0NzAsMjQgKzE0NzEsMjQgQEAg
c3RhdGljIGlubGluZSBjaGFyICpsaWJlcnRhc190cmFuc2xhdGVfcwogCWl3ZS5jbWQgPSBTSU9D
R0lXQVA7CiAJaXdlLnUuYXBfYWRkci5zYV9mYW1pbHkgPSBBUlBIUkRfRVRIRVI7CiAJbWVtY3B5
KGl3ZS51LmFwX2FkZHIuc2FfZGF0YSwgJmJzcy0+YnNzaWQsIEVUSF9BTEVOKTsKLQlzdGFydCA9
IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KHN0YXJ0LCBzdG9wLCAmaXdlLCBJV19FVl9BRERSX0xFTik7
CisJc3RhcnQgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChpbmZvLCBzdGFydCwgc3RvcCwgJml3ZSwg
SVdfRVZfQUREUl9MRU4pOwogCiAJLyogU1NJRCAqLwogCWl3ZS5jbWQgPSBTSU9DR0lXRVNTSUQ7
CiAJaXdlLnUuZGF0YS5mbGFncyA9IDE7CiAJaXdlLnUuZGF0YS5sZW5ndGggPSBtaW4oKHUzMikg
YnNzLT5zc2lkX2xlbiwgKHUzMikgSVdfRVNTSURfTUFYX1NJWkUpOwotCXN0YXJ0ID0gaXdlX3N0
cmVhbV9hZGRfcG9pbnQoc3RhcnQsIHN0b3AsICZpd2UsIGJzcy0+c3NpZCk7CisJc3RhcnQgPSBp
d2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBzdGFydCwgc3RvcCwgJml3ZSwgYnNzLT5zc2lkKTsK
IAogCS8qIE1vZGUgKi8KIAlpd2UuY21kID0gU0lPQ0dJV01PREU7CiAJaXdlLnUubW9kZSA9IGJz
cy0+bW9kZTsKLQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KHN0YXJ0LCBzdG9wLCAmaXdl
LCBJV19FVl9VSU5UX0xFTik7CisJc3RhcnQgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChpbmZvLCBz
dGFydCwgc3RvcCwgJml3ZSwgSVdfRVZfVUlOVF9MRU4pOwogCiAJLyogRnJlcXVlbmN5ICovCiAJ
aXdlLmNtZCA9IFNJT0NHSVdGUkVROwogCWl3ZS51LmZyZXEubSA9IChsb25nKWNmcC0+ZnJlcSAq
IDEwMDAwMDsKIAlpd2UudS5mcmVxLmUgPSAxOwotCXN0YXJ0ID0gaXdlX3N0cmVhbV9hZGRfZXZl
bnQoc3RhcnQsIHN0b3AsICZpd2UsIElXX0VWX0ZSRVFfTEVOKTsKKwlzdGFydCA9IGl3ZV9zdHJl
YW1fYWRkX2V2ZW50KGluZm8sIHN0YXJ0LCBzdG9wLCAmaXdlLCBJV19FVl9GUkVRX0xFTik7CiAK
IAkvKiBBZGQgcXVhbGl0eSBzdGF0aXN0aWNzICovCiAJaXdlLmNtZCA9IElXRVZRVUFMOwpAQCAt
MTUyMyw3ICsxNTI0LDcgQEAgc3RhdGljIGlubGluZSBjaGFyICpsaWJlcnRhc190cmFuc2xhdGVf
cwogCQluZiA9IGFkYXB0ZXItPk5GW1RZUEVfUlhQRF1bVFlQRV9BVkddIC8gQVZHX1NDQUxFOwog
CQlpd2UudS5xdWFsLmxldmVsID0gQ0FMX1JTU0koc25yLCBuZik7CiAJfQotCXN0YXJ0ID0gaXdl
X3N0cmVhbV9hZGRfZXZlbnQoc3RhcnQsIHN0b3AsICZpd2UsIElXX0VWX1FVQUxfTEVOKTsKKwlz
dGFydCA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIHN0YXJ0LCBzdG9wLCAmaXdlLCBJV19F
Vl9RVUFMX0xFTik7CiAKIAkvKiBBZGQgZW5jcnlwdGlvbiBjYXBhYmlsaXR5ICovCiAJaXdlLmNt
ZCA9IFNJT0NHSVdFTkNPREU7CkBAIC0xNTMzLDkgKzE1MzQsMTYgQEAgc3RhdGljIGlubGluZSBj
aGFyICpsaWJlcnRhc190cmFuc2xhdGVfcwogCQlpd2UudS5kYXRhLmZsYWdzID0gSVdfRU5DT0RF
X0RJU0FCTEVEOwogCX0KIAlpd2UudS5kYXRhLmxlbmd0aCA9IDA7Ci0Jc3RhcnQgPSBpd2Vfc3Ry
ZWFtX2FkZF9wb2ludChzdGFydCwgc3RvcCwgJml3ZSwgYnNzLT5zc2lkKTsKKwlzdGFydCA9IGl3
ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIHN0YXJ0LCBzdG9wLCAmaXdlLCBic3MtPnNzaWQpOwog
CisjaWZkZWYgQ09ORklHX0NPTVBBVAorCWlmIChpbmZvLT5mbGFncyAmIElXX1JFUVVFU1RfRkxB
R19DT01QQVQpCisJCWN1cnJlbnRfdmFsID0gc3RhcnQgKyBJV19FVl9DT01BVF9MQ1BfTEVOOwor
CWVsc2UKKwkJY3VycmVudF92YWwgPSBzdGFydCArIElXX0VWX0xDUF9MRU47CisjZWxzZQogCWN1
cnJlbnRfdmFsID0gc3RhcnQgKyBJV19FVl9MQ1BfTEVOOworI2VuZGlmCiAKIAlpd2UuY21kID0g
U0lPQ0dJV1JBVEU7CiAJaXdlLnUuYml0cmF0ZS5maXhlZCA9IDA7CkBAIC0xNTQ1LDggKzE1NTMs
OCBAQCBzdGF0aWMgaW5saW5lIGNoYXIgKmxpYmVydGFzX3RyYW5zbGF0ZV9zCiAJZm9yIChqID0g
MDsgYnNzLT5yYXRlc1tqXSAmJiAoaiA8IHNpemVvZihic3MtPnJhdGVzKSk7IGorKykgewogCQkv
KiBCaXQgcmF0ZSBnaXZlbiBpbiA1MDAga2IvcyB1bml0cyAqLwogCQlpd2UudS5iaXRyYXRlLnZh
bHVlID0gYnNzLT5yYXRlc1tqXSAqIDUwMDAwMDsKLQkJY3VycmVudF92YWwgPSBpd2Vfc3RyZWFt
X2FkZF92YWx1ZShzdGFydCwgY3VycmVudF92YWwsCi0JCQkJCSBzdG9wLCAmaXdlLCBJV19FVl9Q
QVJBTV9MRU4pOworCQljdXJyZW50X3ZhbCA9IGl3ZV9zdHJlYW1fYWRkX3ZhbHVlKGluZm8sIHN0
YXJ0LCBjdXJyZW50X3ZhbCwKKwkJCQkJCSAgIHN0b3AsICZpd2UsIElXX0VWX1BBUkFNX0xFTik7
CiAJfQogCWlmICgoYnNzLT5tb2RlID09IElXX01PREVfQURIT0MpCiAJICAgICYmICFsaWJlcnRh
c19zc2lkX2NtcChhZGFwdGVyLT5jdXJic3NwYXJhbXMuc3NpZCwKQEAgLTE1NTQsOCArMTU2Miw4
IEBAIHN0YXRpYyBpbmxpbmUgY2hhciAqbGliZXJ0YXNfdHJhbnNsYXRlX3MKIAkgICAgICAgICAg
ICAgICAgICAgICAgICAgIGJzcy0+c3NpZCwgYnNzLT5zc2lkX2xlbikKIAkgICAgJiYgYWRhcHRl
ci0+YWRob2NjcmVhdGUpIHsKIAkJaXdlLnUuYml0cmF0ZS52YWx1ZSA9IDIyICogNTAwMDAwOwot
CQljdXJyZW50X3ZhbCA9IGl3ZV9zdHJlYW1fYWRkX3ZhbHVlKHN0YXJ0LCBjdXJyZW50X3ZhbCwK
LQkJCQkJIHN0b3AsICZpd2UsIElXX0VWX1BBUkFNX0xFTik7CisJCWN1cnJlbnRfdmFsID0gaXdl
X3N0cmVhbV9hZGRfdmFsdWUoaW5mbywgc3RhcnQsIGN1cnJlbnRfdmFsLAorCQkJCQkJICAgc3Rv
cCwgJml3ZSwgSVdfRVZfUEFSQU1fTEVOKTsKIAl9CiAJLyogQ2hlY2sgaWYgd2UgYWRkZWQgYW55
IGV2ZW50ICovCiAJaWYoKGN1cnJlbnRfdmFsIC0gc3RhcnQpID4gSVdfRVZfTENQX0xFTikKQEAg
LTE1NjcsNyArMTU3NSw3IEBAIHN0YXRpYyBpbmxpbmUgY2hhciAqbGliZXJ0YXNfdHJhbnNsYXRl
X3MKIAkJbWVtY3B5KGJ1ZiwgYnNzLT53cGFfaWUsIGJzcy0+d3BhX2llX2xlbik7CiAJCWl3ZS5j
bWQgPSBJV0VWR0VOSUU7CiAJCWl3ZS51LmRhdGEubGVuZ3RoID0gYnNzLT53cGFfaWVfbGVuOwot
CQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KHN0YXJ0LCBzdG9wLCAmaXdlLCBidWYpOwor
CQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIHN0YXJ0LCBzdG9wLCAmaXdlLCBi
dWYpOwogCX0KIAogCW1lbXNldCgmaXdlLCAwLCBzaXplb2YoaXdlKSk7CkBAIC0xNTc2LDcgKzE1
ODQsNyBAQCBzdGF0aWMgaW5saW5lIGNoYXIgKmxpYmVydGFzX3RyYW5zbGF0ZV9zCiAJCW1lbWNw
eShidWYsIGJzcy0+cnNuX2llLCBic3MtPnJzbl9pZV9sZW4pOwogCQlpd2UuY21kID0gSVdFVkdF
TklFOwogCQlpd2UudS5kYXRhLmxlbmd0aCA9IGJzcy0+cnNuX2llX2xlbjsKLQkJc3RhcnQgPSBp
d2Vfc3RyZWFtX2FkZF9wb2ludChzdGFydCwgc3RvcCwgJml3ZSwgYnVmKTsKKwkJc3RhcnQgPSBp
d2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBzdGFydCwgc3RvcCwgJml3ZSwgYnVmKTsKIAl9CiAK
IAlpZiAoYnNzLT5tZXNoKSB7CkBAIC0xNTg4LDcgKzE1OTYsOCBAQCBzdGF0aWMgaW5saW5lIGNo
YXIgKmxpYmVydGFzX3RyYW5zbGF0ZV9zCiAJCSAgICAgICAgICAgICAgIm1lc2gtdHlwZTogb2xw
YyIpOwogCQlpd2UudS5kYXRhLmxlbmd0aCA9IHAgLSBjdXN0b207CiAJCWlmIChpd2UudS5kYXRh
Lmxlbmd0aCkKLQkJCXN0YXJ0ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoc3RhcnQsIHN0b3AsICZp
d2UsIGN1c3RvbSk7CisJCQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIHN0YXJ0
LCBzdG9wLAorCQkJCQkJICAgICAmaXdlLCBjdXN0b20pOwogCX0KIAogb3V0OgpAQCAtMTY1MCw3
ICsxNjU5LDggQEAgaW50IGxpYmVydGFzX2dldF9zY2FuKHN0cnVjdCBuZXRfZGV2aWNlIAogCQl9
CiAKIAkJLyogVHJhbnNsYXRlIHRvIFdFIGZvcm1hdCB0aGlzIGVudHJ5ICovCi0JCW5leHRfZXYg
PSBsaWJlcnRhc190cmFuc2xhdGVfc2Nhbihwcml2LCBldiwgc3RvcCwgaXRlcl9ic3MpOworCQlu
ZXh0X2V2ID0gbGliZXJ0YXNfdHJhbnNsYXRlX3NjYW4ocHJpdiwgaW5mbywgZXYsIHN0b3AsCisJ
CQkJCQkgIGl0ZXJfYnNzKTsKIAkJaWYgKG5leHRfZXYgPT0gTlVMTCkKIAkJCWNvbnRpbnVlOwog
CQlldiA9IG5leHRfZXY7Ci0tLSBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL29yaW5vY28uYworKysg
Yi9kcml2ZXJzL25ldC93aXJlbGVzcy9vcmlub2NvLmMKQEAgLTM5MDksNiArMzkwOSw3IEBAIHN0
YXRpYyBpbnQgb3Jpbm9jb19pb2N0bF9zZXRzY2FuKHN0cnVjdCAKICAqIGZvcm1hdCB0aGF0IHRo
ZSBXaXJlbGVzcyBUb29scyB3aWxsIHVuZGVyc3RhbmQgLSBKZWFuIElJCiAgKiBSZXR1cm4gbWVz
c2FnZSBsZW5ndGggb3IgLWVycm5vIGZvciBmYXRhbCBlcnJvcnMgKi8KIHN0YXRpYyBpbmxpbmUg
aW50IG9yaW5vY29fdHJhbnNsYXRlX3NjYW4oc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKKwkJCQkJ
IHN0cnVjdCBpd19yZXF1ZXN0X2luZm8gKmluZm8sCiAJCQkJCSBjaGFyICpidWZmZXIsCiAJCQkJ
CSBjaGFyICpzY2FuLAogCQkJCQkgaW50IHNjYW5fbGVuKQpAQCAtMzk3OSw3ICszOTgwLDggQEAg
c3RhdGljIGlubGluZSBpbnQgb3Jpbm9jb190cmFuc2xhdGVfc2NhbgogCQlpd2UuY21kID0gU0lP
Q0dJV0FQOwogCQlpd2UudS5hcF9hZGRyLnNhX2ZhbWlseSA9IEFSUEhSRF9FVEhFUjsKIAkJbWVt
Y3B5KGl3ZS51LmFwX2FkZHIuc2FfZGF0YSwgYXRvbS0+YS5ic3NpZCwgRVRIX0FMRU4pOwotCQlj
dXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoY3VycmVudF9ldiwgZW5kX2J1ZiwgJml3
ZSwgSVdfRVZfQUREUl9MRU4pOworCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQo
aW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJCSAgJml3ZSwgSVdfRVZfQUREUl9MRU4p
OwogCiAJCS8qIE90aGVyIGVudHJpZXMgd2lsbCBiZSBkaXNwbGF5ZWQgaW4gdGhlIG9yZGVyIHdl
IGdpdmUgdGhlbSAqLwogCkBAIC0zOTg5LDcgKzM5OTEsOCBAQCBzdGF0aWMgaW5saW5lIGludCBv
cmlub2NvX3RyYW5zbGF0ZV9zY2FuCiAJCQlpd2UudS5kYXRhLmxlbmd0aCA9IDMyOwogCQlpd2Uu
Y21kID0gU0lPQ0dJV0VTU0lEOwogCQlpd2UudS5kYXRhLmZsYWdzID0gMTsKLQkJY3VycmVudF9l
diA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsIGF0b20t
PmEuZXNzaWQpOworCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoaW5mbywgY3Vy
cmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJCSAgJml3ZSwgYXRvbS0+YS5lc3NpZCk7CiAKIAkJLyog
QWRkIG1vZGUgKi8KIAkJaXdlLmNtZCA9IFNJT0NHSVdNT0RFOwpAQCAtMzk5OSw3ICs0MDAyLDkg
QEAgc3RhdGljIGlubGluZSBpbnQgb3Jpbm9jb190cmFuc2xhdGVfc2NhbgogCQkJCWl3ZS51Lm1v
ZGUgPSBJV19NT0RFX01BU1RFUjsKIAkJCWVsc2UKIAkJCQlpd2UudS5tb2RlID0gSVdfTU9ERV9B
REhPQzsKLQkJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChjdXJyZW50X2V2LCBl
bmRfYnVmLCAmaXdlLCBJV19FVl9VSU5UX0xFTik7CisJCQljdXJyZW50X2V2ID0gaXdlX3N0cmVh
bV9hZGRfZXZlbnQoaW5mbywgY3VycmVudF9ldiwKKwkJCQkJCQkgIGVuZF9idWYsICZpd2UsCisJ
CQkJCQkJICBJV19FVl9VSU5UX0xFTik7CiAJCX0KIAogCQljaGFubmVsID0gYXRvbS0+cy5jaGFu
bmVsOwpAQCAtNDAwOCw4ICs0MDEzLDkgQEAgc3RhdGljIGlubGluZSBpbnQgb3Jpbm9jb190cmFu
c2xhdGVfc2NhbgogCQkJaXdlLmNtZCA9IFNJT0NHSVdGUkVROwogCQkJaXdlLnUuZnJlcS5tID0g
Y2hhbm5lbF9mcmVxdWVuY3lbY2hhbm5lbC0xXSAqIDEwMDAwMDsKIAkJCWl3ZS51LmZyZXEuZSA9
IDE7Ci0JCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoY3VycmVudF9ldiwgZW5k
X2J1ZiwKLQkJCQkJCQkgICZpd2UsIElXX0VWX0ZSRVFfTEVOKTsKKwkJCWN1cnJlbnRfZXYgPSBp
d2Vfc3RyZWFtX2FkZF9ldmVudChpbmZvLCBjdXJyZW50X2V2LAorCQkJCQkJCSAgZW5kX2J1Ziwg
Jml3ZSwKKwkJCQkJCQkgIElXX0VWX0ZSRVFfTEVOKTsKIAkJfQogCiAJCS8qIEFkZCBxdWFsaXR5
IHN0YXRpc3RpY3MgKi8KQEAgLTQwMjMsNyArNDAyOSw4IEBAIHN0YXRpYyBpbmxpbmUgaW50IG9y
aW5vY29fdHJhbnNsYXRlX3NjYW4KIAkJCWl3ZS51LnF1YWwucXVhbCA9IGl3ZS51LnF1YWwubGV2
ZWwgLSBpd2UudS5xdWFsLm5vaXNlOwogCQllbHNlCiAJCQlpd2UudS5xdWFsLnF1YWwgPSAwOwot
CQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoY3VycmVudF9ldiwgZW5kX2J1Ziwg
Jml3ZSwgSVdfRVZfUVVBTF9MRU4pOworCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZl
bnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJCSAgJml3ZSwgSVdfRVZfUVVBTF9M
RU4pOwogCiAJCS8qIEFkZCBlbmNyeXB0aW9uIGNhcGFiaWxpdHkgKi8KIAkJaXdlLmNtZCA9IFNJ
T0NHSVdFTkNPREU7CkBAIC00MDMyLDE0ICs0MDM5LDIyIEBAIHN0YXRpYyBpbmxpbmUgaW50IG9y
aW5vY29fdHJhbnNsYXRlX3NjYW4KIAkJZWxzZQogCQkJaXdlLnUuZGF0YS5mbGFncyA9IElXX0VO
Q09ERV9ESVNBQkxFRDsKIAkJaXdlLnUuZGF0YS5sZW5ndGggPSAwOwotCQljdXJyZW50X2V2ID0g
aXdlX3N0cmVhbV9hZGRfcG9pbnQoY3VycmVudF9ldiwgZW5kX2J1ZiwgJml3ZSwgYXRvbS0+YS5l
c3NpZCk7CisJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBjdXJyZW50
X2V2LCBlbmRfYnVmLAorCQkJCQkJICAmaXdlLCBhdG9tLT5hLmVzc2lkKTsKIAogCQkvKiBCaXQg
cmF0ZSBpcyBub3QgYXZhaWxhYmxlIGluIEx1Y2VudC9BZ2VyZSBmaXJtd2FyZXMgKi8KIAkJaWYg
KHByaXYtPmZpcm13YXJlX3R5cGUgIT0gRklSTVdBUkVfVFlQRV9BR0VSRSkgewotCQkJY2hhciAq
CWN1cnJlbnRfdmFsID0gY3VycmVudF9ldiArIElXX0VWX0xDUF9MRU47CisJCQljaGFyICpjdXJy
ZW50X3ZhbDsKIAkJCWludAlpOwogCQkJaW50CXN0ZXA7Ci0KKyNpZmRlZiBDT05GSUdfQ09NUEFU
CisJCQlpZiAoaW5mby0+ZmxhZ3MgJiBJV19SRVFVRVNUX0ZMQUdfQ09NUEFUKQorCQkJCWN1cnJl
bnRfdmFsID0gY3VycmVudF9ldiArIElXX0VWX0NPTVBBVF9MQ1BfTEVOOworCQkJZWxzZQorCQkJ
CWN1cnJlbnRfdmFsID0gY3VycmVudF9ldiArIElXX0VWX0xDUF9MRU47CisjZWxzZQorCQkJY3Vy
cmVudF92YWwgPSBjdXJyZW50X2V2ICsgSVdfRVZfTENQX0xFTjsKKyNlbmRpZgogCQkJaWYgKHBy
aXYtPmZpcm13YXJlX3R5cGUgPT0gRklSTVdBUkVfVFlQRV9TWU1CT0wpCiAJCQkJc3RlcCA9IDI7
CiAJCQllbHNlCkBAIC00MDU1LDkgKzQwNzAsOSBAQCBzdGF0aWMgaW5saW5lIGludCBvcmlub2Nv
X3RyYW5zbGF0ZV9zY2FuCiAJCQkJCWJyZWFrOwogCQkJCS8qIEJpdCByYXRlIGdpdmVuIGluIDUw
MCBrYi9zIHVuaXRzICgrIDB4ODApICovCiAJCQkJaXdlLnUuYml0cmF0ZS52YWx1ZSA9ICgoYXRv
bS0+cC5yYXRlc1tpXSAmIDB4N2YpICogNTAwMDAwKTsKLQkJCQljdXJyZW50X3ZhbCA9IGl3ZV9z
dHJlYW1fYWRkX3ZhbHVlKGN1cnJlbnRfZXYsIGN1cnJlbnRfdmFsLAotCQkJCQkJCQkgICBlbmRf
YnVmLCAmaXdlLAotCQkJCQkJCQkgICBJV19FVl9QQVJBTV9MRU4pOworCQkJCWN1cnJlbnRfdmFs
ID0gaXdlX3N0cmVhbV9hZGRfdmFsdWUoCisJCQkJCWluZm8sIGN1cnJlbnRfZXYsIGN1cnJlbnRf
dmFsLAorCQkJCQllbmRfYnVmLCAmaXdlLCBJV19FVl9QQVJBTV9MRU4pOwogCQkJfQogCQkJLyog
Q2hlY2sgaWYgd2UgYWRkZWQgYW55IGV2ZW50ICovCiAJCQlpZiAoKGN1cnJlbnRfdmFsIC0gY3Vy
cmVudF9ldikgPiBJV19FVl9MQ1BfTEVOKQpAQCAtNDEwMiw3ICs0MTE3LDcgQEAgc3RhdGljIGlu
dCBvcmlub2NvX2lvY3RsX2dldHNjYW4oc3RydWN0IAogCQkvKiBXZSBoYXZlIHNvbWUgcmVzdWx0
cyB0byBwdXNoIGJhY2sgdG8gdXNlciBzcGFjZSAqLwogCiAJCS8qIFRyYW5zbGF0ZSB0byBXRSBm
b3JtYXQgKi8KLQkJaW50IHJldCA9IG9yaW5vY29fdHJhbnNsYXRlX3NjYW4oZGV2LCBleHRyYSwK
KwkJaW50IHJldCA9IG9yaW5vY29fdHJhbnNsYXRlX3NjYW4oZGV2LCBpbmZvLCBleHRyYSwKIAkJ
CQkJCSBwcml2LT5zY2FuX3Jlc3VsdCwKIAkJCQkJCSBwcml2LT5zY2FuX2xlbik7CiAKLS0tIGEv
ZHJpdmVycy9uZXQvd2lyZWxlc3MvcHJpc201NC9pc2xfaW9jdGwuYworKysgYi9kcml2ZXJzL25l
dC93aXJlbGVzcy9wcmlzbTU0L2lzbF9pb2N0bC5jCkBAIC01NzIsOCArNTcyLDkgQEAgcHJpc201
NF9zZXRfc2NhbihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LAogICovCiAKIHN0YXRpYyBjaGFyICoK
LXByaXNtNTRfdHJhbnNsYXRlX2JzcyhzdHJ1Y3QgbmV0X2RldmljZSAqbmRldiwgY2hhciAqY3Vy
cmVudF9ldiwKLQkJICAgICAgY2hhciAqZW5kX2J1Ziwgc3RydWN0IG9ial9ic3MgKmJzcywgY2hh
ciBub2lzZSkKK3ByaXNtNTRfdHJhbnNsYXRlX2JzcyhzdHJ1Y3QgbmV0X2RldmljZSAqbmRldiwg
c3RydWN0IGl3X3JlcXVlc3RfaW5mbyAqaW5mbywKKwkJICAgICAgY2hhciAqY3VycmVudF9ldiwg
Y2hhciAqZW5kX2J1Ziwgc3RydWN0IG9ial9ic3MgKmJzcywKKwkJICAgICAgY2hhciBub2lzZSkK
IHsKIAlzdHJ1Y3QgaXdfZXZlbnQgaXdlOwkvKiBUZW1wb3JhcnkgYnVmZmVyICovCiAJc2hvcnQg
Y2FwOwpAQCAtNTg1LDggKzU4Niw4IEBAIHByaXNtNTRfdHJhbnNsYXRlX2JzcyhzdHJ1Y3QgbmV0
X2RldmljZSAKIAltZW1jcHkoaXdlLnUuYXBfYWRkci5zYV9kYXRhLCBic3MtPmFkZHJlc3MsIDYp
OwogCWl3ZS51LmFwX2FkZHIuc2FfZmFtaWx5ID0gQVJQSFJEX0VUSEVSOwogCWl3ZS5jbWQgPSBT
SU9DR0lXQVA7Ci0JY3VycmVudF9ldiA9Ci0JICAgIGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1cnJl
bnRfZXYsIGVuZF9idWYsICZpd2UsIElXX0VWX0FERFJfTEVOKTsKKwljdXJyZW50X2V2ID0gaXdl
X3N0cmVhbV9hZGRfZXZlbnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJICAmaXdl
LCBJV19FVl9BRERSX0xFTik7CiAKIAkvKiBUaGUgZm9sbG93aW5nIGVudHJpZXMgd2lsbCBiZSBk
aXNwbGF5ZWQgaW4gdGhlIHNhbWUgb3JkZXIgd2UgZ2l2ZSB0aGVtICovCiAKQEAgLTU5NCw3ICs1
OTUsNyBAQCBwcmlzbTU0X3RyYW5zbGF0ZV9ic3Moc3RydWN0IG5ldF9kZXZpY2UgCiAJaXdlLnUu
ZGF0YS5sZW5ndGggPSBic3MtPnNzaWQubGVuZ3RoOwogCWl3ZS51LmRhdGEuZmxhZ3MgPSAxOwog
CWl3ZS5jbWQgPSBTSU9DR0lXRVNTSUQ7Ci0JY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3Bv
aW50KGN1cnJlbnRfZXYsIGVuZF9idWYsCisJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3Bv
aW50KGluZm8sIGN1cnJlbnRfZXYsIGVuZF9idWYsCiAJCQkJCSAgJml3ZSwgYnNzLT5zc2lkLm9j
dGV0cyk7CiAKIAkvKiBDYXBhYmlsaXRpZXMgKi8KQEAgLTYxMSw5ICs2MTIsOCBAQCBwcmlzbTU0
X3RyYW5zbGF0ZV9ic3Moc3RydWN0IG5ldF9kZXZpY2UgCiAJCWl3ZS51Lm1vZGUgPSBJV19NT0RF
X0FESE9DOwogCWl3ZS5jbWQgPSBTSU9DR0lXTU9ERTsKIAlpZiAoaXdlLnUubW9kZSkKLQkJY3Vy
cmVudF9ldiA9Ci0JCSAgICBpd2Vfc3RyZWFtX2FkZF9ldmVudChjdXJyZW50X2V2LCBlbmRfYnVm
LCAmaXdlLAotCQkJCQkgSVdfRVZfVUlOVF9MRU4pOworCQljdXJyZW50X2V2ID0gaXdlX3N0cmVh
bV9hZGRfZXZlbnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJCSAgJml3ZSwgSVdf
RVZfVUlOVF9MRU4pOwogCiAJLyogRW5jcnlwdGlvbiBjYXBhYmlsaXR5ICovCiAJaWYgKGNhcCAm
IENBUF9DUllQVCkKQEAgLTYyMiwxNCArNjIyLDE1IEBAIHByaXNtNTRfdHJhbnNsYXRlX2Jzcyhz
dHJ1Y3QgbmV0X2RldmljZSAKIAkJaXdlLnUuZGF0YS5mbGFncyA9IElXX0VOQ09ERV9ESVNBQkxF
RDsKIAlpd2UudS5kYXRhLmxlbmd0aCA9IDA7CiAJaXdlLmNtZCA9IFNJT0NHSVdFTkNPREU7Ci0J
Y3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZp
d2UsIE5VTEwpOworCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBjdXJy
ZW50X2V2LCBlbmRfYnVmLAorCQkJCQkgICZpd2UsIE5VTEwpOwogCiAJLyogQWRkIGZyZXF1ZW5j
eS4gKHNob3J0KSBic3MtPmNoYW5uZWwgaXMgdGhlIGZyZXF1ZW5jeSBpbiBNSHogKi8KIAlpd2Uu
dS5mcmVxLm0gPSBic3MtPmNoYW5uZWw7CiAJaXdlLnUuZnJlcS5lID0gNjsKIAlpd2UuY21kID0g
U0lPQ0dJV0ZSRVE7Ci0JY3VycmVudF9ldiA9Ci0JICAgIGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1
cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsIElXX0VWX0ZSRVFfTEVOKTsKKwljdXJyZW50X2V2ID0g
aXdlX3N0cmVhbV9hZGRfZXZlbnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJICAm
aXdlLCBJV19FVl9GUkVRX0xFTik7CiAKIAkvKiBBZGQgcXVhbGl0eSBzdGF0aXN0aWNzICovCiAJ
aXdlLnUucXVhbC5sZXZlbCA9IGJzcy0+cnNzaTsKQEAgLTYzNywyNCArNjM4LDMyIEBAIHByaXNt
NTRfdHJhbnNsYXRlX2JzcyhzdHJ1Y3QgbmV0X2RldmljZSAKIAkvKiBkbyBhIHNpbXBsZSBTTlIg
Zm9yIHF1YWxpdHkgKi8KIAlpd2UudS5xdWFsLnF1YWwgPSBic3MtPnJzc2kgLSBub2lzZTsKIAlp
d2UuY21kID0gSVdFVlFVQUw7Ci0JY3VycmVudF9ldiA9Ci0JICAgIGl3ZV9zdHJlYW1fYWRkX2V2
ZW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsIElXX0VWX1FVQUxfTEVOKTsKKwljdXJyZW50
X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJ
CQkJICAmaXdlLCBJV19FVl9RVUFMX0xFTik7CiAKIAkvKiBBZGQgV1BBL1JTTiBJbmZvcm1hdGlv
biBFbGVtZW50LCBpZiBhbnkgKi8KIAl3cGFfaWVfbGVuID0gcHJpc201NF93cGFfYnNzX2llX2dl
dChwcml2LCBic3MtPmFkZHJlc3MsIHdwYV9pZSk7CiAJaWYgKHdwYV9pZV9sZW4gPiAwKSB7CiAJ
CWl3ZS5jbWQgPSBJV0VWR0VOSUU7CiAJCWl3ZS51LmRhdGEubGVuZ3RoID0gbWluKHdwYV9pZV9s
ZW4sIChzaXplX3QpTUFYX1dQQV9JRV9MRU4pOwotCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9h
ZGRfcG9pbnQoY3VycmVudF9ldiwgZW5kX2J1ZiwKLQkJCQkmaXdlLCB3cGFfaWUpOworCQljdXJy
ZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwK
KwkJCQkJCSAgJml3ZSwgd3BhX2llKTsKIAl9CiAJLyogRG8gdGhlIGJpdHJhdGVzICovCiAJewot
CQljaGFyICoJY3VycmVudF92YWwgPSBjdXJyZW50X2V2ICsgSVdfRVZfTENQX0xFTjsKKwkJY2hh
ciAqY3VycmVudF92YWw7CiAJCWludCBpOwogCQlpbnQgbWFzazsKIAogCQlpd2UuY21kID0gU0lP
Q0dJV1JBVEU7CisjaWZkZWYgQ09ORklHX0NPTVBBVAorCQlpZiAoaW5mby0+ZmxhZ3MgJiBJV19S
RVFVRVNUX0ZMQUdfQ09NUEFUKQorCQkJY3VycmVudF92YWwgPSBjdXJyZW50X2V2ICsgSVdfRVZf
Q09NUEFUX0xDUF9MRU47CisJCWVsc2UKKwkJCWN1cnJlbnRfdmFsID0gY3VycmVudF9ldiArIElX
X0VWX0xDUF9MRU47CisjZWxzZQorCQljdXJyZW50X3ZhbCA9IGN1cnJlbnRfZXYgKyBJV19FVl9M
Q1BfTEVOOworI2VuZGlmCiAJCS8qIFRob3NlIHR3byBmbGFncyBhcmUgaWdub3JlZC4uLiAqLwog
CQlpd2UudS5iaXRyYXRlLmZpeGVkID0gaXdlLnUuYml0cmF0ZS5kaXNhYmxlZCA9IDA7CiAKQEAg
LTY2Myw5ICs2NzIsOSBAQCBwcmlzbTU0X3RyYW5zbGF0ZV9ic3Moc3RydWN0IG5ldF9kZXZpY2Ug
CiAJCWZvcihpID0gMDsgaSA8IHNpemVvZihzY2FuX3JhdGVfbGlzdCk7IGkrKykgewogCQkJaWYo
YnNzLT5yYXRlcyAmIG1hc2spIHsKIAkJCQlpd2UudS5iaXRyYXRlLnZhbHVlID0gKHNjYW5fcmF0
ZV9saXN0W2ldICogNTAwMDAwKTsKLQkJCQljdXJyZW50X3ZhbCA9IGl3ZV9zdHJlYW1fYWRkX3Zh
bHVlKGN1cnJlbnRfZXYsIGN1cnJlbnRfdmFsLAotCQkJCQkJCQkgICBlbmRfYnVmLCAmaXdlLAot
CQkJCQkJCQkgICBJV19FVl9QQVJBTV9MRU4pOworCQkJCWN1cnJlbnRfdmFsID0gaXdlX3N0cmVh
bV9hZGRfdmFsdWUoCisJCQkJCWluZm8sIGN1cnJlbnRfZXYsIGN1cnJlbnRfdmFsLAorCQkJCQll
bmRfYnVmLCAmaXdlLCBJV19FVl9QQVJBTV9MRU4pOwogCQkJfQogCQkJbWFzayA8PD0gMTsKIAkJ
fQpAQCAtNzExLDcgKzcyMCw3IEBAIHByaXNtNTRfZ2V0X3NjYW4oc3RydWN0IG5ldF9kZXZpY2Ug
Km5kZXYKIAogCS8qIG9rIG5vdywgc2NhbiB0aGUgbGlzdCBhbmQgdHJhbnNsYXRlIGl0cyBpbmZv
ICovCiAJZm9yIChpID0gMDsgaSA8IChpbnQpIGJzc2xpc3QtPm5yOyBpKyspIHsKLQkJY3VycmVu
dF9ldiA9IHByaXNtNTRfdHJhbnNsYXRlX2JzcyhuZGV2LCBjdXJyZW50X2V2LAorCQljdXJyZW50
X2V2ID0gcHJpc201NF90cmFuc2xhdGVfYnNzKG5kZXYsIGluZm8sIGN1cnJlbnRfZXYsCiAJCQkJ
CQkgICBleHRyYSArIGR3cnEtPmxlbmd0aCwKIAkJCQkJCSAgICYoYnNzbGlzdC0+YnNzbGlzdFtp
XSksCiAJCQkJCQkgICBub2lzZSk7CkBAIC0yNzA1LDYgKzI3MTQsNyBAQCBwcmlzbTJfaW9jdGxf
c2Nhbl9yZXEoc3RydWN0IG5ldF9kZXZpY2UgCiAgICAgICAgICAgICAgICAgICAgICBzdHJ1Y3Qg
cHJpc20yX2hvc3RhcGRfcGFyYW0gKnBhcmFtKQogewogCWlzbHBjaV9wcml2YXRlICpwcml2ID0g
bmV0ZGV2X3ByaXYobmRldik7CisJc3RydWN0IGl3X3JlcXVlc3RfaW5mbyBpbmZvOwogCWludCBp
LCBydmFsdWU7CiAJc3RydWN0IG9ial9ic3NsaXN0ICpic3NsaXN0OwogCXUzMiBub2lzZSA9IDA7
CkBAIC0yNzI4LDkgKzI3MzgsMTIgQEAgcHJpc20yX2lvY3RsX3NjYW5fcmVxKHN0cnVjdCBuZXRf
ZGV2aWNlIAogCXJ2YWx1ZSB8PSBtZ3RfZ2V0X3JlcXVlc3QocHJpdiwgRE9UMTFfT0lEX0JTU0xJ
U1QsIDAsIE5VTEwsICZyKTsKIAlic3NsaXN0ID0gci5wdHI7CiAKKwlpbmZvLmNtZCA9IFBSSVNN
NTRfSE9TVEFQRDsKKwlpbmZvLmZsYWdzID0gMDsKKwogCS8qIG9rIG5vdywgc2NhbiB0aGUgbGlz
dCBhbmQgdHJhbnNsYXRlIGl0cyBpbmZvICovCiAJZm9yIChpID0gMDsgaSA8IG1pbihJV19NQVhf
QVAsIChpbnQpIGJzc2xpc3QtPm5yKTsgaSsrKQotCQljdXJyZW50X2V2ID0gcHJpc201NF90cmFu
c2xhdGVfYnNzKG5kZXYsIGN1cnJlbnRfZXYsCisJCWN1cnJlbnRfZXYgPSBwcmlzbTU0X3RyYW5z
bGF0ZV9ic3MobmRldiwgY3VycmVudF9ldiwgJmluZm8sCiAJCQkJCQkgICBleHRyYSArIElXX1ND
QU5fTUFYX0RBVEEsCiAJCQkJCQkgICAmKGJzc2xpc3QtPmJzc2xpc3RbaV0pLAogCQkJCQkJICAg
bm9pc2UpOwotLS0gYS9kcml2ZXJzL25ldC93aXJlbGVzcy93bDM1MDFfY3MuYworKysgYi9kcml2
ZXJzL25ldC93aXJlbGVzcy93bDM1MDFfY3MuYwpAQCAtMTYyNCwyNSArMTYyNCwyNSBAQCBzdGF0
aWMgaW50IHdsMzUwMV9nZXRfc2NhbihzdHJ1Y3QgbmV0X2RlCiAJCWl3ZS5jbWQJCQk9IFNJT0NH
SVdBUDsKIAkJaXdlLnUuYXBfYWRkci5zYV9mYW1pbHkgPSBBUlBIUkRfRVRIRVI7CiAJCW1lbWNw
eShpd2UudS5hcF9hZGRyLnNhX2RhdGEsIHRoaXMtPmJzc19zZXRbaV0uYnNzaWQsIEVUSF9BTEVO
KTsKLQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1cnJlbnRfZXYsCisJCWN1
cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChpbmZvLCBjdXJyZW50X2V2LAogCQkJCQkJ
ICBleHRyYSArIElXX1NDQU5fTUFYX0RBVEEsCiAJCQkJCQkgICZpd2UsIElXX0VWX0FERFJfTEVO
KTsKIAkJaXdlLmNtZAkJICA9IFNJT0NHSVdFU1NJRDsKIAkJaXdlLnUuZGF0YS5mbGFncyAgPSAx
OwogCQlpd2UudS5kYXRhLmxlbmd0aCA9IHRoaXMtPmJzc19zZXRbaV0uc3NpZC5lbC5sZW47Ci0J
CWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChjdXJyZW50X2V2LAorCQljdXJyZW50
X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoaW5mbywgY3VycmVudF9ldiwKIAkJCQkJCSAgZXh0
cmEgKyBJV19TQ0FOX01BWF9EQVRBLAogCQkJCQkJICAmaXdlLAogCQkJCQkJICB0aGlzLT5ic3Nf
c2V0W2ldLnNzaWQuZXNzaWQpOwogCQlpd2UuY21kCSAgID0gU0lPQ0dJV01PREU7CiAJCWl3ZS51
Lm1vZGUgPSB0aGlzLT5ic3Nfc2V0W2ldLmJzc190eXBlOwotCQljdXJyZW50X2V2ID0gaXdlX3N0
cmVhbV9hZGRfZXZlbnQoY3VycmVudF9ldiwKKwkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRk
X2V2ZW50KGluZm8sIGN1cnJlbnRfZXYsCiAJCQkJCQkgIGV4dHJhICsgSVdfU0NBTl9NQVhfREFU
QSwKIAkJCQkJCSAgJml3ZSwgSVdfRVZfVUlOVF9MRU4pOwogCQlpd2UuY21kID0gU0lPQ0dJV0ZS
RVE7CiAJCWl3ZS51LmZyZXEubSA9IHRoaXMtPmJzc19zZXRbaV0uZHNfcHNldC5jaGFuOwogCQlp
d2UudS5mcmVxLmUgPSAwOwotCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoY3Vy
cmVudF9ldiwKKwkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1cnJl
bnRfZXYsCiAJCQkJCQkgIGV4dHJhICsgSVdfU0NBTl9NQVhfREFUQSwKIAkJCQkJCSAgJml3ZSwg
SVdfRVZfRlJFUV9MRU4pOwogCQlpd2UuY21kID0gU0lPQ0dJV0VOQ09ERTsKQEAgLTE2NTEsNyAr
MTY1MSw3IEBAIHN0YXRpYyBpbnQgd2wzNTAxX2dldF9zY2FuKHN0cnVjdCBuZXRfZGUKIAkJZWxz
ZQogCQkJaXdlLnUuZGF0YS5mbGFncyA9IElXX0VOQ09ERV9ESVNBQkxFRDsKIAkJaXdlLnUuZGF0
YS5sZW5ndGggPSAwOwotCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoY3VycmVu
dF9ldiwKKwkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIGN1cnJlbnRf
ZXYsCiAJCQkJCQkgIGV4dHJhICsgSVdfU0NBTl9NQVhfREFUQSwKIAkJCQkJCSAgJml3ZSwgTlVM
TCk7CiAJfQotLS0gYS9kcml2ZXJzL25ldC93aXJlbGVzcy96ZDEyMDEuYworKysgYi9kcml2ZXJz
L25ldC93aXJlbGVzcy96ZDEyMDEuYwpAQCAtMTE1MiwzMiArMTE1MiwzNiBAQCBzdGF0aWMgaW50
IHpkMTIwMV9nZXRfc2NhbihzdHJ1Y3QgbmV0X2RlCiAJCWl3ZS5jbWQgPSBTSU9DR0lXQVA7CiAJ
CWl3ZS51LmFwX2FkZHIuc2FfZmFtaWx5ID0gQVJQSFJEX0VUSEVSOwogCQltZW1jcHkoaXdlLnUu
YXBfYWRkci5zYV9kYXRhLCB6ZC0+cnhkYXRhK2krNiwgNik7Ci0JCWNldiA9IGl3ZV9zdHJlYW1f
YWRkX2V2ZW50KGNldiwgZW5kX2J1ZiwgJml3ZSwgSVdfRVZfQUREUl9MRU4pOworCQljZXYgPSBp
d2Vfc3RyZWFtX2FkZF9ldmVudChpbmZvLCBjZXYsIGVuZF9idWYsCisJCQkJCSAgICZpd2UsIElX
X0VWX0FERFJfTEVOKTsKIAogCQlpd2UuY21kID0gU0lPQ0dJV0VTU0lEOwogCQlpd2UudS5kYXRh
Lmxlbmd0aCA9IHpkLT5yeGRhdGFbaSsxNl07CiAJCWl3ZS51LmRhdGEuZmxhZ3MgPSAxOwotCQlj
ZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChjZXYsIGVuZF9idWYsICZpd2UsIHpkLT5yeGRhdGEr
aSsxOCk7CisJCWNldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIGNldiwgZW5kX2J1ZiwK
KwkJCQkJICAgJml3ZSwgemQtPnJ4ZGF0YStpKzE4KTsKIAogCQlpd2UuY21kID0gU0lPQ0dJV01P
REU7CiAJCWlmICh6ZC0+cnhkYXRhW2krMTRdJjB4MDEpCiAJCQlpd2UudS5tb2RlID0gSVdfTU9E
RV9NQVNURVI7CiAJCWVsc2UKIAkJCWl3ZS51Lm1vZGUgPSBJV19NT0RFX0FESE9DOwotCQljZXYg
PSBpd2Vfc3RyZWFtX2FkZF9ldmVudChjZXYsIGVuZF9idWYsICZpd2UsIElXX0VWX1VJTlRfTEVO
KTsKKwkJY2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoaW5mbywgY2V2LCBlbmRfYnVmLAorCQkJ
CQkgICAmaXdlLCBJV19FVl9VSU5UX0xFTik7CiAJCQogCQlpd2UuY21kID0gU0lPQ0dJV0ZSRVE7
CiAJCWl3ZS51LmZyZXEubSA9IHpkLT5yeGRhdGFbaSswXTsKIAkJaXdlLnUuZnJlcS5lID0gMDsK
LQkJY2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoY2V2LCBlbmRfYnVmLCAmaXdlLCBJV19FVl9G
UkVRX0xFTik7CisJCWNldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGNldiwgZW5kX2J1
ZiwKKwkJCQkJICAgJml3ZSwgSVdfRVZfRlJFUV9MRU4pOwogCQkKIAkJaXdlLmNtZCA9IFNJT0NH
SVdSQVRFOwogCQlpd2UudS5iaXRyYXRlLmZpeGVkID0gMDsKIAkJaXdlLnUuYml0cmF0ZS5kaXNh
YmxlZCA9IDA7CiAJCWZvciAoaj0wOyBqPDEwOyBqKyspIGlmICh6ZC0+cnhkYXRhW2krNTAral0p
IHsKIAkJCWl3ZS51LmJpdHJhdGUudmFsdWUgPSAoemQtPnJ4ZGF0YVtpKzUwK2pdJjB4N2YpKjUw
MDAwMDsKLQkJCWNldj1pd2Vfc3RyZWFtX2FkZF9ldmVudChjZXYsIGVuZF9idWYsICZpd2UsCi0J
CQkgICAgSVdfRVZfUEFSQU1fTEVOKTsKKwkJCWNldj1pd2Vfc3RyZWFtX2FkZF9ldmVudChpbmZv
LCBjZXYsIGVuZF9idWYsCisJCQkJCQkgJml3ZSwgSVdfRVZfUEFSQU1fTEVOKTsKIAkJfQogCQkK
IAkJaXdlLmNtZCA9IFNJT0NHSVdFTkNPREU7CkBAIC0xMTg2LDE0ICsxMTkwLDE1IEBAIHN0YXRp
YyBpbnQgemQxMjAxX2dldF9zY2FuKHN0cnVjdCBuZXRfZGUKIAkJCWl3ZS51LmRhdGEuZmxhZ3Mg
PSBJV19FTkNPREVfRU5BQkxFRDsKIAkJZWxzZQogCQkJaXdlLnUuZGF0YS5mbGFncyA9IElXX0VO
Q09ERV9ESVNBQkxFRDsKLQkJY2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoY2V2LCBlbmRfYnVm
LCAmaXdlLCBOVUxMKTsKKwkJY2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoaW5mbywgY2V2LCBl
bmRfYnVmLCAmaXdlLCBOVUxMKTsKIAkJCiAJCWl3ZS5jbWQgPSBJV0VWUVVBTDsKIAkJaXdlLnUu
cXVhbC5xdWFsID0gemQtPnJ4ZGF0YVtpKzRdOwogCQlpd2UudS5xdWFsLm5vaXNlPSB6ZC0+cnhk
YXRhW2krMl0vMTAtMTAwOwogCQlpd2UudS5xdWFsLmxldmVsID0gKDI1Nit6ZC0+cnhkYXRhW2kr
NF0qMTAwKS8yNTUtMTAwOwogCQlpd2UudS5xdWFsLnVwZGF0ZWQgPSA3OwotCQljZXYgPSBpd2Vf
c3RyZWFtX2FkZF9ldmVudChjZXYsIGVuZF9idWYsICZpd2UsIElXX0VWX1FVQUxfTEVOKTsKKwkJ
Y2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoaW5mbywgY2V2LCBlbmRfYnVmLAorCQkJCQkgICAm
aXdlLCBJV19FVl9RVUFMX0xFTik7CiAJfQogCiAJaWYgKCFlbmFibGVkX3NhdmUpCi0tLSBhL2lu
Y2x1ZGUvbGludXgvd2lyZWxlc3MuaAorKysgYi9pbmNsdWRlL2xpbnV4L3dpcmVsZXNzLmgKQEAg
LTEwOTgsNiArMTA5OCwxOSBAQCBzdHJ1Y3QgaXdfZXZlbnQKICNkZWZpbmUgSVdfRVZfUE9JTlRf
TEVOCShJV19FVl9MQ1BfTEVOICsgc2l6ZW9mKHN0cnVjdCBpd19wb2ludCkgLSBcCiAJCQkgSVdf
RVZfUE9JTlRfT0ZGKQogCisjaWYgZGVmaW5lZChfX0tFUk5FTF9fKSAmJiBkZWZpbmVkKENPTkZJ
R19DT01QQVQpCitzdHJ1Y3QgX19jb21wYXRfaXdfZXZlbnQgeworCV9fdTE2CQlsZW47CQkJLyog
UmVhbCBsZW5ndGggb2YgdGhpcyBzdHVmZiAqLworCV9fdTE2CQljbWQ7CQkJLyogV2lyZWxlc3Mg
SU9DVEwgKi8KKwljb21wYXRfY2FkZHJfdAlwb2ludGVyOworfTsKKyNkZWZpbmUgSVdfRVZfQ09N
UEFUX0xDUF9MRU4gb2Zmc2V0b2Yoc3RydWN0IF9fY29tcGF0X2l3X2V2ZW50LCBwb2ludGVyKQor
I2RlZmluZSBJV19FVl9DT01QQVRfUE9JTlRfT0ZGIG9mZnNldG9mKHN0cnVjdCBjb21wYXRfaXdf
cG9pbnQsIGxlbmd0aCkKKyNkZWZpbmUgSVdfRVZfQ09NUEFUX1BPSU5UX0xFTglcCisJKElXX0VW
X0NPTVBBVF9MQ1BfTEVOICsgc2l6ZW9mKHN0cnVjdCBjb21wYXRfaXdfcG9pbnQpIC0gXAorCSBJ
V19FVl9DT01QQVRfUE9JTlRfT0ZGKQorI2VuZGlmCisKIC8qIFNpemUgb2YgdGhlIEV2ZW50IHBy
ZWZpeCB3aGVuIHBhY2tlZCBpbiBzdHJlYW0gKi8KICNkZWZpbmUgSVdfRVZfTENQX1BLX0xFTgko
NCkKIC8qIFNpemUgb2YgdGhlIHZhcmlvdXMgZXZlbnRzIHdoZW4gcGFja2VkIGluIHN0cmVhbSAq
LwotLS0gYS9pbmNsdWRlL25ldC9pd19oYW5kbGVyLmgKKysrIGIvaW5jbHVkZS9uZXQvaXdfaGFu
ZGxlci5oCkBAIC00ODMsMTkgKzQ4MywyNiBAQCBleHRlcm4gdm9pZCB3aXJlbGVzc19zcHlfdXBk
YXRlKHN0cnVjdCBuCiAgKiBXcmFwcGVyIHRvIGFkZCBhbiBXaXJlbGVzcyBFdmVudCB0byBhIHN0
cmVhbSBvZiBldmVudHMuCiAgKi8KIHN0YXRpYyBpbmxpbmUgY2hhciAqCi1pd2Vfc3RyZWFtX2Fk
ZF9ldmVudChjaGFyICoJc3RyZWFtLAkJLyogU3RyZWFtIG9mIGV2ZW50cyAqLwotCQkgICAgIGNo
YXIgKgllbmRzLAkJLyogRW5kIG9mIHN0cmVhbSAqLwotCQkgICAgIHN0cnVjdCBpd19ldmVudCAq
aXdlLAkvKiBQYXlsb2FkICovCi0JCSAgICAgaW50CWV2ZW50X2xlbikJLyogUmVhbCBzaXplIG9m
IHBheWxvYWQgKi8KK2l3ZV9zdHJlYW1fYWRkX2V2ZW50KHN0cnVjdCBpd19yZXF1ZXN0X2luZm8g
KmluZm8sIGNoYXIgKnN0cmVhbSwgY2hhciAqZW5kcywKKwkJICAgICBzdHJ1Y3QgaXdfZXZlbnQg
Kml3ZSwgaW50IGV2ZW50X2xlbikKIHsKKwlpbnQgbGNwX2xlbiA9IElXX0VWX0xDUF9MRU47CisJ
aW50IG9yZ19ldmVudF9sZW4gPSBldmVudF9sZW47CisKKyNpZmRlZiBDT05GSUdfQ09NUEFUCisJ
aWYgKGluZm8tPmZsYWdzICYgSVdfUkVRVUVTVF9GTEFHX0NPTVBBVCkgeworCQlldmVudF9sZW4g
LT0gSVdfRVZfTENQX0xFTjsKKwkJZXZlbnRfbGVuICs9IElXX0VWX0NPTVBBVF9MQ1BfTEVOOwor
CQlsY3BfbGVuID0gSVdfRVZfQ09NUEFUX0xDUF9MRU47CisJfQorI2VuZGlmCiAJLyogQ2hlY2sg
aWYgaXQncyBwb3NzaWJsZSAqLwogCWlmKGxpa2VseSgoc3RyZWFtICsgZXZlbnRfbGVuKSA8IGVu
ZHMpKSB7CiAJCWl3ZS0+bGVuID0gZXZlbnRfbGVuOwogCQkvKiBCZXdhcmUgb2YgYWxpZ25lbWVu
dCBpc3N1ZXMgb24gNjQgYml0cyAqLwogCQltZW1jcHkoc3RyZWFtLCAoY2hhciAqKSBpd2UsIElX
X0VWX0xDUF9QS19MRU4pOwotCQltZW1jcHkoc3RyZWFtICsgSVdfRVZfTENQX0xFTiwKLQkJICAg
ICAgICgoY2hhciAqKSBpd2UpICsgSVdfRVZfTENQX0xFTiwKLQkJICAgICAgIGV2ZW50X2xlbiAt
IElXX0VWX0xDUF9MRU4pOworCQltZW1jcHkoc3RyZWFtICsgbGNwX2xlbiwgJml3ZS0+dSwKKwkJ
ICAgICAgIG9yZ19ldmVudF9sZW4gLSBJV19FVl9MQ1BfTEVOKTsKIAkJc3RyZWFtICs9IGV2ZW50
X2xlbjsKIAl9CiAJcmV0dXJuIHN0cmVhbTsKQEAgLTUwNywxMDQgKzUxNCwzMSBAQCBpd2Vfc3Ry
ZWFtX2FkZF9ldmVudChjaGFyICoJc3RyZWFtLAkJLyogCiAgKiBzdHJlYW0gb2YgZXZlbnRzLgog
ICovCiBzdGF0aWMgaW5saW5lIGNoYXIgKgotaXdlX3N0cmVhbV9hZGRfcG9pbnQoY2hhciAqCXN0
cmVhbSwJCS8qIFN0cmVhbSBvZiBldmVudHMgKi8KLQkJICAgICBjaGFyICoJZW5kcywJCS8qIEVu
ZCBvZiBzdHJlYW0gKi8KLQkJICAgICBzdHJ1Y3QgaXdfZXZlbnQgKml3ZSwJLyogUGF5bG9hZCBs
ZW5ndGggKyBmbGFncyAqLwotCQkgICAgIGNoYXIgKglleHRyYSkJCS8qIE1vcmUgcGF5bG9hZCAq
LwotewotCWludAlldmVudF9sZW4gPSBJV19FVl9QT0lOVF9MRU4gKyBpd2UtPnUuZGF0YS5sZW5n
dGg7Ci0JLyogQ2hlY2sgaWYgaXQncyBwb3NzaWJsZSAqLwotCWlmKGxpa2VseSgoc3RyZWFtICsg
ZXZlbnRfbGVuKSA8IGVuZHMpKSB7Ci0JCWl3ZS0+bGVuID0gZXZlbnRfbGVuOwotCQltZW1jcHko
c3RyZWFtLCAoY2hhciAqKSBpd2UsIElXX0VWX0xDUF9QS19MRU4pOwotCQltZW1jcHkoc3RyZWFt
ICsgSVdfRVZfTENQX0xFTiwKLQkJICAgICAgICgoY2hhciAqKSBpd2UpICsgSVdfRVZfTENQX0xF
TiArIElXX0VWX1BPSU5UX09GRiwKLQkJICAgICAgIElXX0VWX1BPSU5UX1BLX0xFTiAtIElXX0VW
X0xDUF9QS19MRU4pOwotCQltZW1jcHkoc3RyZWFtICsgSVdfRVZfUE9JTlRfTEVOLCBleHRyYSwg
aXdlLT51LmRhdGEubGVuZ3RoKTsKLQkJc3RyZWFtICs9IGV2ZW50X2xlbjsKLQl9Ci0JcmV0dXJu
IHN0cmVhbTsKLX0KLQotLyotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0qLwotLyoKLSAqIFdyYXBwZXIgdG8gYWRkIGEgdmFs
dWUgdG8gYSBXaXJlbGVzcyBFdmVudCBpbiBhIHN0cmVhbSBvZiBldmVudHMuCi0gKiBCZSBjYXJl
ZnVsLCB0aGlzIG9uZSBpcyB0cmlja3kgdG8gdXNlIHByb3Blcmx5IDoKLSAqIEF0IHRoZSBmaXJz
dCBydW4sIHlvdSBuZWVkIHRvIGhhdmUgKHZhbHVlID0gZXZlbnQgKyBJV19FVl9MQ1BfTEVOKS4K
LSAqLwotc3RhdGljIGlubGluZSBjaGFyICoKLWl3ZV9zdHJlYW1fYWRkX3ZhbHVlKGNoYXIgKgll
dmVudCwJCS8qIEV2ZW50IGluIHRoZSBzdHJlYW0gKi8KLQkJICAgICBjaGFyICoJdmFsdWUsCQkv
KiBWYWx1ZSBpbiBldmVudCAqLwotCQkgICAgIGNoYXIgKgllbmRzLAkJLyogRW5kIG9mIHN0cmVh
bSAqLwotCQkgICAgIHN0cnVjdCBpd19ldmVudCAqaXdlLAkvKiBQYXlsb2FkICovCi0JCSAgICAg
aW50CWV2ZW50X2xlbikJLyogUmVhbCBzaXplIG9mIHBheWxvYWQgKi8KK2l3ZV9zdHJlYW1fYWRk
X3BvaW50KHN0cnVjdCBpd19yZXF1ZXN0X2luZm8gKmluZm8sIGNoYXIgKnN0cmVhbSwgY2hhciAq
ZW5kcywKKwkJICAgICBzdHJ1Y3QgaXdfZXZlbnQgKml3ZSwgY2hhciAqZXh0cmEpCiB7Ci0JLyog
RG9uJ3QgZHVwbGljYXRlIExDUCAqLwotCWV2ZW50X2xlbiAtPSBJV19FVl9MQ1BfTEVOOwotCi0J
LyogQ2hlY2sgaWYgaXQncyBwb3NzaWJsZSAqLwotCWlmKGxpa2VseSgodmFsdWUgKyBldmVudF9s
ZW4pIDwgZW5kcykpIHsKLQkJLyogQWRkIG5ldyB2YWx1ZSAqLwotCQltZW1jcHkodmFsdWUsIChj
aGFyICopIGl3ZSArIElXX0VWX0xDUF9MRU4sIGV2ZW50X2xlbik7Ci0JCXZhbHVlICs9IGV2ZW50
X2xlbjsKLQkJLyogUGF0Y2ggTENQICovCi0JCWl3ZS0+bGVuID0gdmFsdWUgLSBldmVudDsKLQkJ
bWVtY3B5KGV2ZW50LCAoY2hhciAqKSBpd2UsIElXX0VWX0xDUF9MRU4pOworCWludCBldmVudF9s
ZW4gPSBJV19FVl9QT0lOVF9MRU4gKyBpd2UtPnUuZGF0YS5sZW5ndGg7CisJaW50IHBvaW50X2xl
biA9IElXX0VWX1BPSU5UX0xFTjsKKwlpbnQgbGNwX2xlbiA9IElXX0VWX0xDUF9MRU47CisKKyNp
ZmRlZiBDT05GSUdfQ09NUEFUCisJaWYgKGluZm8tPmZsYWdzICYgSVdfUkVRVUVTVF9GTEFHX0NP
TVBBVCkgeworCQlldmVudF9sZW4gPSBJV19FVl9DT01QQVRfUE9JTlRfTEVOICsgaXdlLT51LmRh
dGEubGVuZ3RoOworCQlwb2ludF9sZW4gPSBJV19FVl9DT01QQVRfUE9JTlRfTEVOOworCQlsY3Bf
bGVuID0gSVdfRVZfQ09NUEFUX0xDUF9MRU47CiAJfQotCXJldHVybiB2YWx1ZTsKLX0KLQotLyot
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0qLwotLyoKLSAqIFdyYXBwZXIgdG8gYWRkIGFuIFdpcmVsZXNzIEV2ZW50IHRvIGEg
c3RyZWFtIG9mIGV2ZW50cy4KLSAqIFNhbWUgYXMgYWJvdmUsIHdpdGggZXhwbGljaXQgZXJyb3Ig
Y2hlY2suLi4KLSAqLwotc3RhdGljIGlubGluZSBjaGFyICoKLWl3ZV9zdHJlYW1fY2hlY2tfYWRk
X2V2ZW50KGNoYXIgKglzdHJlYW0sCQkvKiBTdHJlYW0gb2YgZXZlbnRzICovCi0JCQkgICBjaGFy
ICoJZW5kcywJCS8qIEVuZCBvZiBzdHJlYW0gKi8KLQkJCSAgIHN0cnVjdCBpd19ldmVudCAqaXdl
LAkvKiBQYXlsb2FkICovCi0JCQkgICBpbnQJCWV2ZW50X2xlbiwJLyogU2l6ZSBvZiBwYXlsb2Fk
ICovCi0JCQkgICBpbnQgKglwZXJyKQkJLyogRXJyb3IgcmVwb3J0ICovCi17Ci0JLyogQ2hlY2sg
aWYgaXQncyBwb3NzaWJsZSwgc2V0IGVycm9yIGlmIG5vdCAqLwotCWlmKGxpa2VseSgoc3RyZWFt
ICsgZXZlbnRfbGVuKSA8IGVuZHMpKSB7Ci0JCWl3ZS0+bGVuID0gZXZlbnRfbGVuOwotCQkvKiBC
ZXdhcmUgb2YgYWxpZ25lbWVudCBpc3N1ZXMgb24gNjQgYml0cyAqLwotCQltZW1jcHkoc3RyZWFt
LCAoY2hhciAqKSBpd2UsIElXX0VWX0xDUF9QS19MRU4pOwotCQltZW1jcHkoc3RyZWFtICsgSVdf
RVZfTENQX0xFTiwKLQkJICAgICAgICgoY2hhciAqKSBpd2UpICsgSVdfRVZfTENQX0xFTiwKLQkJ
ICAgICAgIGV2ZW50X2xlbiAtIElXX0VWX0xDUF9MRU4pOwotCQlzdHJlYW0gKz0gZXZlbnRfbGVu
OwotCX0gZWxzZQotCQkqcGVyciA9IC1FMkJJRzsKLQlyZXR1cm4gc3RyZWFtOwotfQorI2VuZGlm
CiAKLS8qLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tKi8KLS8qCi0gKiBXcmFwcGVyIHRvIGFkZCBhbiBzaG9ydCBXaXJlbGVz
cyBFdmVudCBjb250YWluaW5nIGEgcG9pbnRlciB0byBhCi0gKiBzdHJlYW0gb2YgZXZlbnRzLgot
ICogU2FtZSBhcyBhYm92ZSwgd2l0aCBleHBsaWNpdCBlcnJvciBjaGVjay4uLgotICovCi1zdGF0
aWMgaW5saW5lIGNoYXIgKgotaXdlX3N0cmVhbV9jaGVja19hZGRfcG9pbnQoY2hhciAqCXN0cmVh
bSwJCS8qIFN0cmVhbSBvZiBldmVudHMgKi8KLQkJCSAgIGNoYXIgKgllbmRzLAkJLyogRW5kIG9m
IHN0cmVhbSAqLwotCQkJICAgc3RydWN0IGl3X2V2ZW50ICppd2UsCS8qIFBheWxvYWQgbGVuZ3Ro
ICsgZmxhZ3MgKi8KLQkJCSAgIGNoYXIgKglleHRyYSwJCS8qIE1vcmUgcGF5bG9hZCAqLwotCQkJ
ICAgaW50ICoJcGVycikJCS8qIEVycm9yIHJlcG9ydCAqLwotewotCWludAlldmVudF9sZW4gPSBJ
V19FVl9QT0lOVF9MRU4gKyBpd2UtPnUuZGF0YS5sZW5ndGg7CiAJLyogQ2hlY2sgaWYgaXQncyBw
b3NzaWJsZSAqLwogCWlmKGxpa2VseSgoc3RyZWFtICsgZXZlbnRfbGVuKSA8IGVuZHMpKSB7CiAJ
CWl3ZS0+bGVuID0gZXZlbnRfbGVuOwogCQltZW1jcHkoc3RyZWFtLCAoY2hhciAqKSBpd2UsIElX
X0VWX0xDUF9QS19MRU4pOwotCQltZW1jcHkoc3RyZWFtICsgSVdfRVZfTENQX0xFTiwKLQkJICAg
ICAgICgoY2hhciAqKSBpd2UpICsgSVdfRVZfTENQX0xFTiArIElXX0VWX1BPSU5UX09GRiwKKwkJ
bWVtY3B5KHN0cmVhbSArIGxjcF9sZW4sCisJCSAgICAgICAmaXdlLT51LmRhdGEubGVuZ3RoLAog
CQkgICAgICAgSVdfRVZfUE9JTlRfUEtfTEVOIC0gSVdfRVZfTENQX1BLX0xFTik7Ci0JCW1lbWNw
eShzdHJlYW0gKyBJV19FVl9QT0lOVF9MRU4sIGV4dHJhLCBpd2UtPnUuZGF0YS5sZW5ndGgpOwor
CQltZW1jcHkoc3RyZWFtICsgcG9pbnRfbGVuLCBleHRyYSwgaXdlLT51LmRhdGEubGVuZ3RoKTsK
IAkJc3RyZWFtICs9IGV2ZW50X2xlbjsKLQl9IGVsc2UKLQkJKnBlcnIgPSAtRTJCSUc7CisJfQog
CXJldHVybiBzdHJlYW07CiB9CiAKQEAgLTYxMiwzMCArNTQ2LDM4IEBAIGl3ZV9zdHJlYW1fY2hl
Y2tfYWRkX3BvaW50KGNoYXIgKglzdHJlYW0KIC8qCiAgKiBXcmFwcGVyIHRvIGFkZCBhIHZhbHVl
IHRvIGEgV2lyZWxlc3MgRXZlbnQgaW4gYSBzdHJlYW0gb2YgZXZlbnRzLgogICogQmUgY2FyZWZ1
bCwgdGhpcyBvbmUgaXMgdHJpY2t5IHRvIHVzZSBwcm9wZXJseSA6Ci0gKiBBdCB0aGUgZmlyc3Qg
cnVuLCB5b3UgbmVlZCB0byBoYXZlICh2YWx1ZSA9IGV2ZW50ICsgSVdfRVZfTENQX0xFTikuCi0g
KiBTYW1lIGFzIGFib3ZlLCB3aXRoIGV4cGxpY2l0IGVycm9yIGNoZWNrLi4uCi0gKi8KLXN0YXRp
YyBpbmxpbmUgY2hhciAqCi1pd2Vfc3RyZWFtX2NoZWNrX2FkZF92YWx1ZShjaGFyICoJZXZlbnQs
CQkvKiBFdmVudCBpbiB0aGUgc3RyZWFtICovCi0JCQkgICBjaGFyICoJdmFsdWUsCQkvKiBWYWx1
ZSBpbiBldmVudCAqLwotCQkJICAgY2hhciAqCWVuZHMsCQkvKiBFbmQgb2Ygc3RyZWFtICovCi0J
CQkgICBzdHJ1Y3QgaXdfZXZlbnQgKml3ZSwJLyogUGF5bG9hZCAqLwotCQkJICAgaW50CQlldmVu
dF9sZW4sCS8qIFNpemUgb2YgcGF5bG9hZCAqLwotCQkJICAgaW50ICoJcGVycikJCS8qIEVycm9y
IHJlcG9ydCAqLwoteworICogQXQgdGhlIGZpcnN0IHJ1biwgeW91IG5lZWQgdG8gaGF2ZSB0aGUg
Y29kZSBsaWtlOgorICogI2lmZGVmIENPTkZJR19DT01QQVQKKyAqIGlmIChpbmZvLT5mbGFncyAm
IElXX1JFUVVFU1RfRkxBR19DT01QQVQpCisgKiAJdmFsdWUgPSBldiArIElXX0VWX0NPTVBBVF9M
Q1BfTEVOOworICogZWxzZQorICogCXZhbHVlID0gZXYgKyBJV19FVl9DT01QQVRfTEVOOworICog
I2Vsc2UKKyAqIHZhbHVlID0gZXYgKyBJV19FVl9DT01QQVRfTEVOOworICogI2VuZGlmCisgKi8K
K3N0YXRpYyBpbmxpbmUgY2hhciAqCitpd2Vfc3RyZWFtX2FkZF92YWx1ZShzdHJ1Y3QgaXdfcmVx
dWVzdF9pbmZvICppbmZvLCBjaGFyICpldmVudCwgY2hhciAqdmFsdWUsCisJCSAgICAgY2hhciAq
ZW5kcywgc3RydWN0IGl3X2V2ZW50ICppd2UsIGludCBldmVudF9sZW4pCit7CisJaW50IGxjcF9s
ZW4gPSBJV19FVl9MQ1BfTEVOOworCisjaWZkZWYgQ09ORklHX0NPTVBBVAorCWlmIChpbmZvLT5m
bGFncyAmIElXX1JFUVVFU1RfRkxBR19DT01QQVQpCisJCWxjcF9sZW4gPSBJV19FVl9DT01QQVRf
TENQX0xFTjsKKyNlbmRpZgogCS8qIERvbid0IGR1cGxpY2F0ZSBMQ1AgKi8KIAlldmVudF9sZW4g
LT0gSVdfRVZfTENQX0xFTjsKIAogCS8qIENoZWNrIGlmIGl0J3MgcG9zc2libGUgKi8KIAlpZihs
aWtlbHkoKHZhbHVlICsgZXZlbnRfbGVuKSA8IGVuZHMpKSB7CiAJCS8qIEFkZCBuZXcgdmFsdWUg
Ki8KLQkJbWVtY3B5KHZhbHVlLCAoY2hhciAqKSBpd2UgKyBJV19FVl9MQ1BfTEVOLCBldmVudF9s
ZW4pOworCQltZW1jcHkodmFsdWUsICZpd2UtPnUsIGV2ZW50X2xlbik7CiAJCXZhbHVlICs9IGV2
ZW50X2xlbjsKIAkJLyogUGF0Y2ggTENQICovCiAJCWl3ZS0+bGVuID0gdmFsdWUgLSBldmVudDsK
LQkJbWVtY3B5KGV2ZW50LCAoY2hhciAqKSBpd2UsIElXX0VWX0xDUF9MRU4pOwotCX0gZWxzZQot
CQkqcGVyciA9IC1FMkJJRzsKKwkJbWVtY3B5KGV2ZW50LCAoY2hhciAqKSBpd2UsIGxjcF9sZW4p
OworCX0KIAlyZXR1cm4gdmFsdWU7CiB9CiAKLS0tIGEvbmV0L2llZWU4MDIxMS9pZWVlODAyMTFf
d3guYworKysgYi9uZXQvaWVlZTgwMjExL2llZWU4MDIxMV93eC5jCkBAIC00Myw4ICs0Myw5IEBA
IHN0YXRpYyBjb25zdCBjaGFyICppZWVlODAyMTFfbW9kZXNbXSA9IHsKIAogI2RlZmluZSBNQVhf
Q1VTVE9NX0xFTiA2NAogc3RhdGljIGNoYXIgKmllZWU4MDIxMV90cmFuc2xhdGVfc2NhbihzdHJ1
Y3QgaWVlZTgwMjExX2RldmljZSAqaWVlZSwKLQkJCQkJICAgY2hhciAqc3RhcnQsIGNoYXIgKnN0
b3AsCi0JCQkJCSAgIHN0cnVjdCBpZWVlODAyMTFfbmV0d29yayAqbmV0d29yaykKKwkJCQkgICAg
ICBjaGFyICpzdGFydCwgY2hhciAqc3RvcCwKKwkJCQkgICAgICBzdHJ1Y3QgaWVlZTgwMjExX25l
dHdvcmsgKm5ldHdvcmssCisJCQkJICAgICAgc3RydWN0IGl3X3JlcXVlc3RfaW5mbyAqaW5mbykK
IHsKIAljaGFyIGN1c3RvbVtNQVhfQ1VTVE9NX0xFTl07CiAJY2hhciAqcDsKQEAgLTU3LDcgKzU4
LDcgQEAgc3RhdGljIGNoYXIgKmllZWU4MDIxMV90cmFuc2xhdGVfc2NhbihzdAogCWl3ZS5jbWQg
PSBTSU9DR0lXQVA7CiAJaXdlLnUuYXBfYWRkci5zYV9mYW1pbHkgPSBBUlBIUkRfRVRIRVI7CiAJ
bWVtY3B5KGl3ZS51LmFwX2FkZHIuc2FfZGF0YSwgbmV0d29yay0+YnNzaWQsIEVUSF9BTEVOKTsK
LQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KHN0YXJ0LCBzdG9wLCAmaXdlLCBJV19FVl9B
RERSX0xFTik7CisJc3RhcnQgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChpbmZvLCBzdGFydCwgc3Rv
cCwgJml3ZSwgSVdfRVZfQUREUl9MRU4pOwogCiAJLyogUmVtYWluaW5nIGVudHJpZXMgd2lsbCBi
ZSBkaXNwbGF5ZWQgaW4gdGhlIG9yZGVyIHdlIHByb3ZpZGUgdGhlbSAqLwogCkBAIC02NiwxNyAr
NjcsMTkgQEAgc3RhdGljIGNoYXIgKmllZWU4MDIxMV90cmFuc2xhdGVfc2NhbihzdAogCWl3ZS51
LmRhdGEuZmxhZ3MgPSAxOwogCWlmIChuZXR3b3JrLT5mbGFncyAmIE5FVFdPUktfRU1QVFlfRVNT
SUQpIHsKIAkJaXdlLnUuZGF0YS5sZW5ndGggPSBzaXplb2YoIjxoaWRkZW4+Iik7Ci0JCXN0YXJ0
ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoc3RhcnQsIHN0b3AsICZpd2UsICI8aGlkZGVuPiIpOwor
CQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIHN0YXJ0LCBzdG9wLAorCQkJCQkg
ICAgICZpd2UsICI8aGlkZGVuPiIpOwogCX0gZWxzZSB7CiAJCWl3ZS51LmRhdGEubGVuZ3RoID0g
bWluKG5ldHdvcmstPnNzaWRfbGVuLCAodTgpIDMyKTsKLQkJc3RhcnQgPSBpd2Vfc3RyZWFtX2Fk
ZF9wb2ludChzdGFydCwgc3RvcCwgJml3ZSwgbmV0d29yay0+c3NpZCk7CisJCXN0YXJ0ID0gaXdl
X3N0cmVhbV9hZGRfcG9pbnQoaW5mbywgc3RhcnQsIHN0b3AsCisJCQkJCSAgICAgJml3ZSwgbmV0
d29yay0+c3NpZCk7CiAJfQogCiAJLyogQWRkIHRoZSBwcm90b2NvbCBuYW1lICovCiAJaXdlLmNt
ZCA9IFNJT0NHSVdOQU1FOwogCXNucHJpbnRmKGl3ZS51Lm5hbWUsIElGTkFNU0laLCAiSUVFRSA4
MDIuMTElcyIsCiAJCSBpZWVlODAyMTFfbW9kZXNbbmV0d29yay0+bW9kZV0pOwotCXN0YXJ0ID0g
aXdlX3N0cmVhbV9hZGRfZXZlbnQoc3RhcnQsIHN0b3AsICZpd2UsIElXX0VWX0NIQVJfTEVOKTsK
KwlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIHN0YXJ0LCBzdG9wLCAmaXdlLCBJ
V19FVl9DSEFSX0xFTik7CiAKIAkvKiBBZGQgbW9kZSAqLwogCWl3ZS5jbWQgPSBTSU9DR0lXTU9E
RTsKQEAgLTg2LDcgKzg5LDggQEAgc3RhdGljIGNoYXIgKmllZWU4MDIxMV90cmFuc2xhdGVfc2Nh
bihzdAogCQllbHNlCiAJCQlpd2UudS5tb2RlID0gSVdfTU9ERV9BREhPQzsKIAotCQlzdGFydCA9
IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KHN0YXJ0LCBzdG9wLCAmaXdlLCBJV19FVl9VSU5UX0xFTik7
CisJCXN0YXJ0ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoaW5mbywgc3RhcnQsIHN0b3AsCisJCQkJ
CSAgICAgJml3ZSwgSVdfRVZfVUlOVF9MRU4pOwogCX0KIAogCS8qIEFkZCBjaGFubmVsIGFuZCBm
cmVxdWVuY3kgKi8KQEAgLTk1LDcgKzk5LDcgQEAgc3RhdGljIGNoYXIgKmllZWU4MDIxMV90cmFu
c2xhdGVfc2NhbihzdAogCWl3ZS51LmZyZXEubSA9IGllZWU4MDIxMV9jaGFubmVsX3RvX2ZyZXEo
aWVlZSwgbmV0d29yay0+Y2hhbm5lbCk7CiAJaXdlLnUuZnJlcS5lID0gNjsKIAlpd2UudS5mcmVx
LmkgPSAwOwotCXN0YXJ0ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoc3RhcnQsIHN0b3AsICZpd2Us
IElXX0VWX0ZSRVFfTEVOKTsKKwlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIHN0
YXJ0LCBzdG9wLCAmaXdlLCBJV19FVl9GUkVRX0xFTik7CiAKIAkvKiBBZGQgZW5jcnlwdGlvbiBj
YXBhYmlsaXR5ICovCiAJaXdlLmNtZCA9IFNJT0NHSVdFTkNPREU7CkBAIC0xMDQsMTIgKzEwOCwy
MCBAQCBzdGF0aWMgY2hhciAqaWVlZTgwMjExX3RyYW5zbGF0ZV9zY2FuKHN0CiAJZWxzZQogCQlp
d2UudS5kYXRhLmZsYWdzID0gSVdfRU5DT0RFX0RJU0FCTEVEOwogCWl3ZS51LmRhdGEubGVuZ3Ro
ID0gMDsKLQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KHN0YXJ0LCBzdG9wLCAmaXdlLCBu
ZXR3b3JrLT5zc2lkKTsKKwlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIHN0YXJ0
LCBzdG9wLAorCQkJCSAgICAgJml3ZSwgbmV0d29yay0+c3NpZCk7CiAKIAkvKiBBZGQgYmFzaWMg
YW5kIGV4dGVuZGVkIHJhdGVzICovCiAJLyogUmF0ZSA6IHN0dWZmaW5nIG11bHRpcGxlIHZhbHVl
cyBpbiBhIHNpbmdsZSBldmVudCByZXF1aXJlIGEgYml0CiAJICogbW9yZSBvZiBtYWdpYyAtIEpl
YW4gSUkgKi8KKyNpZmRlZiBDT05GSUdfQ09NUEFUCisJaWYgKGluZm8tPmZsYWdzICYgSVdfUkVR
VUVTVF9GTEFHX0NPTVBBVCkKKwkJY3VycmVudF92YWwgPSBzdGFydCArIElXX0VWX0NPTVBBVF9M
Q1BfTEVOOworCWVsc2UKKwkJY3VycmVudF92YWwgPSBzdGFydCArIElXX0VWX0xDUF9MRU47Cisj
ZWxzZQogCWN1cnJlbnRfdmFsID0gc3RhcnQgKyBJV19FVl9MQ1BfTEVOOworI2VuZGlmCiAJaXdl
LmNtZCA9IFNJT0NHSVdSQVRFOwogCS8qIFRob3NlIHR3byBmbGFncyBhcmUgaWdub3JlZC4uLiAq
LwogCWl3ZS51LmJpdHJhdGUuZml4ZWQgPSBpd2UudS5iaXRyYXRlLmRpc2FibGVkID0gMDsKQEAg
LTEyNCwxNCArMTM2LDE2IEBAIHN0YXRpYyBjaGFyICppZWVlODAyMTFfdHJhbnNsYXRlX3NjYW4o
c3QKIAkJLyogQml0IHJhdGUgZ2l2ZW4gaW4gNTAwIGtiL3MgdW5pdHMgKCsgMHg4MCkgKi8KIAkJ
aXdlLnUuYml0cmF0ZS52YWx1ZSA9ICgocmF0ZSAmIDB4N2YpICogNTAwMDAwKTsKIAkJLyogQWRk
IG5ldyB2YWx1ZSB0byBldmVudCAqLwotCQljdXJyZW50X3ZhbCA9IGl3ZV9zdHJlYW1fYWRkX3Zh
bHVlKHN0YXJ0LCBjdXJyZW50X3ZhbCwgc3RvcCwgJml3ZSwgSVdfRVZfUEFSQU1fTEVOKTsKKwkJ
Y3VycmVudF92YWwgPSBpd2Vfc3RyZWFtX2FkZF92YWx1ZShpbmZvLCBzdGFydCwgY3VycmVudF92
YWwsCisJCQkJCQkgICBzdG9wLCAmaXdlLCBJV19FVl9QQVJBTV9MRU4pOwogCX0KIAlmb3IgKDsg
aiA8IG5ldHdvcmstPnJhdGVzX2V4X2xlbjsgaisrKSB7CiAJCXJhdGUgPSBuZXR3b3JrLT5yYXRl
c19leFtqXSAmIDB4N0Y7CiAJCS8qIEJpdCByYXRlIGdpdmVuIGluIDUwMCBrYi9zIHVuaXRzICgr
IDB4ODApICovCiAJCWl3ZS51LmJpdHJhdGUudmFsdWUgPSAoKHJhdGUgJiAweDdmKSAqIDUwMDAw
MCk7CiAJCS8qIEFkZCBuZXcgdmFsdWUgdG8gZXZlbnQgKi8KLQkJY3VycmVudF92YWwgPSBpd2Vf
c3RyZWFtX2FkZF92YWx1ZShzdGFydCwgY3VycmVudF92YWwsIHN0b3AsICZpd2UsIElXX0VWX1BB
UkFNX0xFTik7CisJCWN1cnJlbnRfdmFsID0gaXdlX3N0cmVhbV9hZGRfdmFsdWUoaW5mbywgc3Rh
cnQsIGN1cnJlbnRfdmFsLAorCQkJCQkJICAgc3RvcCwgJml3ZSwgSVdfRVZfUEFSQU1fTEVOKTsK
IAl9CiAJLyogQ2hlY2sgaWYgd2UgYWRkZWQgYW55IHJhdGUgKi8KIAlpZigoY3VycmVudF92YWwg
LSBzdGFydCkgPiBJV19FVl9MQ1BfTEVOKQpAQCAtMTgxLDE0ICsxOTUsMTQgQEAgc3RhdGljIGNo
YXIgKmllZWU4MDIxMV90cmFuc2xhdGVfc2NhbihzdAogCQlpd2UudS5xdWFsLmxldmVsID0gbmV0
d29yay0+c3RhdHMuc2lnbmFsOwogCX0KIAotCXN0YXJ0ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQo
c3RhcnQsIHN0b3AsICZpd2UsIElXX0VWX1FVQUxfTEVOKTsKKwlzdGFydCA9IGl3ZV9zdHJlYW1f
YWRkX2V2ZW50KGluZm8sIHN0YXJ0LCBzdG9wLCAmaXdlLCBJV19FVl9RVUFMX0xFTik7CiAKIAlp
d2UuY21kID0gSVdFVkNVU1RPTTsKIAlwID0gY3VzdG9tOwogCiAJaXdlLnUuZGF0YS5sZW5ndGgg
PSBwIC0gY3VzdG9tOwogCWlmIChpd2UudS5kYXRhLmxlbmd0aCkKLQkJc3RhcnQgPSBpd2Vfc3Ry
ZWFtX2FkZF9wb2ludChzdGFydCwgc3RvcCwgJml3ZSwgY3VzdG9tKTsKKwkJc3RhcnQgPSBpd2Vf
c3RyZWFtX2FkZF9wb2ludChpbmZvLCBzdGFydCwgc3RvcCwgJml3ZSwgY3VzdG9tKTsKIAogCW1l
bXNldCgmaXdlLCAwLCBzaXplb2YoaXdlKSk7CiAJaWYgKG5ldHdvcmstPndwYV9pZV9sZW4pIHsK
QEAgLTE5Niw3ICsyMTAsNyBAQCBzdGF0aWMgY2hhciAqaWVlZTgwMjExX3RyYW5zbGF0ZV9zY2Fu
KHN0CiAJCW1lbWNweShidWYsIG5ldHdvcmstPndwYV9pZSwgbmV0d29yay0+d3BhX2llX2xlbik7
CiAJCWl3ZS5jbWQgPSBJV0VWR0VOSUU7CiAJCWl3ZS51LmRhdGEubGVuZ3RoID0gbmV0d29yay0+
d3BhX2llX2xlbjsKLQkJc3RhcnQgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChzdGFydCwgc3RvcCwg
Jml3ZSwgYnVmKTsKKwkJc3RhcnQgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBzdGFydCwg
c3RvcCwgJml3ZSwgYnVmKTsKIAl9CiAKIAltZW1zZXQoJml3ZSwgMCwgc2l6ZW9mKGl3ZSkpOwpA
QCAtMjA1LDcgKzIxOSw3IEBAIHN0YXRpYyBjaGFyICppZWVlODAyMTFfdHJhbnNsYXRlX3NjYW4o
c3QKIAkJbWVtY3B5KGJ1ZiwgbmV0d29yay0+cnNuX2llLCBuZXR3b3JrLT5yc25faWVfbGVuKTsK
IAkJaXdlLmNtZCA9IElXRVZHRU5JRTsKIAkJaXdlLnUuZGF0YS5sZW5ndGggPSBuZXR3b3JrLT5y
c25faWVfbGVuOwotCQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KHN0YXJ0LCBzdG9wLCAm
aXdlLCBidWYpOworCQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIHN0YXJ0LCBz
dG9wLCAmaXdlLCBidWYpOwogCX0KIAogCS8qIEFkZCBFWFRSQTogQWdlIHRvIGRpc3BsYXkgc2Vj
b25kcyBzaW5jZSBsYXN0IGJlYWNvbi9wcm9iZSByZXNwb25zZQpAQCAtMjE3LDcgKzIzMSw3IEBA
IHN0YXRpYyBjaGFyICppZWVlODAyMTFfdHJhbnNsYXRlX3NjYW4oc3QKIAkJICAgICAgamlmZmll
c190b19tc2VjcyhqaWZmaWVzIC0gbmV0d29yay0+bGFzdF9zY2FubmVkKSk7CiAJaXdlLnUuZGF0
YS5sZW5ndGggPSBwIC0gY3VzdG9tOwogCWlmIChpd2UudS5kYXRhLmxlbmd0aCkKLQkJc3RhcnQg
PSBpd2Vfc3RyZWFtX2FkZF9wb2ludChzdGFydCwgc3RvcCwgJml3ZSwgY3VzdG9tKTsKKwkJc3Rh
cnQgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBzdGFydCwgc3RvcCwgJml3ZSwgY3VzdG9t
KTsKIAogCS8qIEFkZCBzcGVjdHJ1bSBtYW5hZ2VtZW50IGluZm9ybWF0aW9uICovCiAJaXdlLmNt
ZCA9IC0xOwpAQCAtMjM4LDcgKzI1Miw3IEBAIHN0YXRpYyBjaGFyICppZWVlODAyMTFfdHJhbnNs
YXRlX3NjYW4oc3QKIAogCWlmIChpd2UuY21kID09IElXRVZDVVNUT00pIHsKIAkJaXdlLnUuZGF0
YS5sZW5ndGggPSBwIC0gY3VzdG9tOwotCQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KHN0
YXJ0LCBzdG9wLCAmaXdlLCBjdXN0b20pOworCQlzdGFydCA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50
KGluZm8sIHN0YXJ0LCBzdG9wLCAmaXdlLCBjdXN0b20pOwogCX0KIAogCXJldHVybiBzdGFydDsK
QEAgLTI3Miw3ICsyODYsOCBAQCBpbnQgaWVlZTgwMjExX3d4X2dldF9zY2FuKHN0cnVjdCBpZWVl
ODAyCiAKIAkJaWYgKGllZWUtPnNjYW5fYWdlID09IDAgfHwKIAkJICAgIHRpbWVfYWZ0ZXIobmV0
d29yay0+bGFzdF9zY2FubmVkICsgaWVlZS0+c2Nhbl9hZ2UsIGppZmZpZXMpKQotCQkJZXYgPSBp
ZWVlODAyMTFfdHJhbnNsYXRlX3NjYW4oaWVlZSwgZXYsIHN0b3AsIG5ldHdvcmspOworCQkJZXYg
PSBpZWVlODAyMTFfdHJhbnNsYXRlX3NjYW4oaWVlZSwgZXYsIHN0b3AsIG5ldHdvcmssCisJCQkJ
CQkgICAgICBpbmZvKTsKIAkJZWxzZQogCQkJSUVFRTgwMjExX0RFQlVHX1NDQU4oIk5vdCBzaG93
aW5nIG5ldHdvcmsgJyVzICgiCiAJCQkJCSAgICAgIiVzKScgZHVlIHRvIGFnZSAoJWRtcykuXG4i
LAotLS0gYS9uZXQvbWFjODAyMTEvaWVlZTgwMjExX2kuaAorKysgYi9uZXQvbWFjODAyMTEvaWVl
ZTgwMjExX2kuaApAQCAtMjMsNiArMjMsNyBAQAogI2luY2x1ZGUgPGxpbnV4L3NwaW5sb2NrLmg+
CiAjaW5jbHVkZSA8bGludXgvZXRoZXJkZXZpY2UuaD4KICNpbmNsdWRlIDxuZXQvd2lyZWxlc3Mu
aD4KKyNpbmNsdWRlIDxuZXQvaXdfaGFuZGxlci5oPgogI2luY2x1ZGUgImllZWU4MDIxMV9rZXku
aCIKICNpbmNsdWRlICJzdGFfaW5mby5oIgogCkBAIC03NDgsNyArNzQ5LDkgQEAgaW50IGllZWU4
MDIxMV9zdGFfc2V0X2Jzc2lkKHN0cnVjdCBuZXRfZAogaW50IGllZWU4MDIxMV9zdGFfcmVxX3Nj
YW4oc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgdTggKnNzaWQsIHNpemVfdCBzc2lkX2xlbik7CiB2
b2lkIGllZWU4MDIxMV9zdGFfcmVxX2F1dGgoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKIAkJCSAg
ICBzdHJ1Y3QgaWVlZTgwMjExX2lmX3N0YSAqaWZzdGEpOwotaW50IGllZWU4MDIxMV9zdGFfc2Nh
bl9yZXN1bHRzKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIGNoYXIgKmJ1Ziwgc2l6ZV90IGxlbik7
CitpbnQgaWVlZTgwMjExX3N0YV9zY2FuX3Jlc3VsdHMoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwK
KwkJCSAgICAgICBzdHJ1Y3QgaXdfcmVxdWVzdF9pbmZvICppbmZvLAorCQkJICAgICAgIGNoYXIg
KmJ1Ziwgc2l6ZV90IGxlbik7CiB2b2lkIGllZWU4MDIxMV9zdGFfcnhfc2NhbihzdHJ1Y3QgbmV0
X2RldmljZSAqZGV2LCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCQkJICAgc3RydWN0IGllZWU4MDIx
MV9yeF9zdGF0dXMgKnJ4X3N0YXR1cyk7CiB2b2lkIGllZWU4MDIxMV9yeF9ic3NfbGlzdF9pbml0
KHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpOwotLS0gYS9uZXQvbWFjODAyMTEvaWVlZTgwMjExX2lv
Y3RsLmMKKysrIGIvbmV0L21hYzgwMjExL2llZWU4MDIxMV9pb2N0bC5jCkBAIC01NjAsNyArNTYw
LDcgQEAgc3RhdGljIGludCBpZWVlODAyMTFfaW9jdGxfZ2l3c2NhbihzdHJ1YwogCXN0cnVjdCBp
ZWVlODAyMTFfbG9jYWwgKmxvY2FsID0gd2Rldl9wcml2KGRldi0+aWVlZTgwMjExX3B0cik7CiAJ
aWYgKGxvY2FsLT5zdGFfc2Nhbm5pbmcpCiAJCXJldHVybiAtRUFHQUlOOwotCXJlcyA9IGllZWU4
MDIxMV9zdGFfc2Nhbl9yZXN1bHRzKGRldiwgZXh0cmEsIGRhdGEtPmxlbmd0aCk7CisJcmVzID0g
aWVlZTgwMjExX3N0YV9zY2FuX3Jlc3VsdHMoZGV2LCBpbmZvLCBleHRyYSwgZGF0YS0+bGVuZ3Ro
KTsKIAlpZiAocmVzID49IDApIHsKIAkJZGF0YS0+bGVuZ3RoID0gcmVzOwogCQlyZXR1cm4gMDsK
LS0tIGEvbmV0L21hYzgwMjExL2llZWU4MDIxMV9zdGEuYworKysgYi9uZXQvbWFjODAyMTEvaWVl
ZTgwMjExX3N0YS5jCkBAIC0yODgxLDYgKzI4ODEsNyBAQCBpbnQgaWVlZTgwMjExX3N0YV9yZXFf
c2NhbihzdHJ1Y3QgbmV0X2RlCiAKIHN0YXRpYyBjaGFyICoKIGllZWU4MDIxMV9zdGFfc2Nhbl9y
ZXN1bHQoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKKwkJCSAgc3RydWN0IGl3X3JlcXVlc3RfaW5m
byAqaW5mbywKIAkJCSAgc3RydWN0IGllZWU4MDIxMV9zdGFfYnNzICpic3MsCiAJCQkgIGNoYXIg
KmN1cnJlbnRfZXYsIGNoYXIgKmVuZF9idWYpCiB7CkBAIC0yOTA3LDE1ICsyOTA4LDE1IEBAIGll
ZWU4MDIxMV9zdGFfc2Nhbl9yZXN1bHQoc3RydWN0IG5ldF9kZXYKIAlpd2UuY21kID0gU0lPQ0dJ
V0FQOwogCWl3ZS51LmFwX2FkZHIuc2FfZmFtaWx5ID0gQVJQSFJEX0VUSEVSOwogCW1lbWNweShp
d2UudS5hcF9hZGRyLnNhX2RhdGEsIGJzcy0+YnNzaWQsIEVUSF9BTEVOKTsKLQljdXJyZW50X2V2
ID0gaXdlX3N0cmVhbV9hZGRfZXZlbnQoY3VycmVudF9ldiwgZW5kX2J1ZiwgJml3ZSwKLQkJCQkJ
ICBJV19FVl9BRERSX0xFTik7CisJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGlu
Zm8sIGN1cnJlbnRfZXYsIGVuZF9idWYsCisJCQkJCSAgJml3ZSwgSVdfRVZfQUREUl9MRU4pOwog
CiAJbWVtc2V0KCZpd2UsIDAsIHNpemVvZihpd2UpKTsKIAlpd2UuY21kID0gU0lPQ0dJV0VTU0lE
OwogCWl3ZS51LmRhdGEubGVuZ3RoID0gYnNzLT5zc2lkX2xlbjsKIAlpd2UudS5kYXRhLmZsYWdz
ID0gMTsKLQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9pbnQoY3VycmVudF9ldiwgZW5k
X2J1ZiwgJml3ZSwKLQkJCQkJICBic3MtPnNzaWQpOworCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFt
X2FkZF9wb2ludChpbmZvLCBjdXJyZW50X2V2LCBlbmRfYnVmLAorCQkJCQkgICZpd2UsIGJzcy0+
c3NpZCk7CiAKIAlpZiAoYnNzLT5jYXBhYmlsaXR5ICYgKFdMQU5fQ0FQQUJJTElUWV9FU1MgfCBX
TEFOX0NBUEFCSUxJVFlfSUJTUykpIHsKIAkJbWVtc2V0KCZpd2UsIDAsIHNpemVvZihpd2UpKTsK
QEAgLTI5MjQsMjAgKzI5MjUsMjAgQEAgaWVlZTgwMjExX3N0YV9zY2FuX3Jlc3VsdChzdHJ1Y3Qg
bmV0X2RldgogCQkJaXdlLnUubW9kZSA9IElXX01PREVfTUFTVEVSOwogCQllbHNlCiAJCQlpd2Uu
dS5tb2RlID0gSVdfTU9ERV9BREhPQzsKLQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2
ZW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsCi0JCQkJCQkgIElXX0VWX1VJTlRfTEVOKTsK
KwkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1cnJlbnRfZXYsIGVu
ZF9idWYsCisJCQkJCQkgICZpd2UsIElXX0VWX1VJTlRfTEVOKTsKIAl9CiAKIAltZW1zZXQoJml3
ZSwgMCwgc2l6ZW9mKGl3ZSkpOwogCWl3ZS5jbWQgPSBTSU9DR0lXRlJFUTsKIAlpd2UudS5mcmVx
Lm0gPSBic3MtPmNoYW5uZWw7CiAJaXdlLnUuZnJlcS5lID0gMDsKLQljdXJyZW50X2V2ID0gaXdl
X3N0cmVhbV9hZGRfZXZlbnQoY3VycmVudF9ldiwgZW5kX2J1ZiwgJml3ZSwKLQkJCQkJICBJV19F
Vl9GUkVRX0xFTik7CisJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGluZm8sIGN1
cnJlbnRfZXYsIGVuZF9idWYsCisJCQkJCSAgJml3ZSwgSVdfRVZfRlJFUV9MRU4pOwogCWl3ZS51
LmZyZXEubSA9IGJzcy0+ZnJlcSAqIDEwMDAwMDsKIAlpd2UudS5mcmVxLmUgPSAxOwotCWN1cnJl
bnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9ldmVudChjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLAot
CQkJCQkgIElXX0VWX0ZSRVFfTEVOKTsKKwljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfZXZl
bnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJICAmaXdlLCBJV19FVl9GUkVRX0xF
Tik7CiAKIAltZW1zZXQoJml3ZSwgMCwgc2l6ZW9mKGl3ZSkpOwogCWl3ZS5jbWQgPSBJV0VWUVVB
TDsKQEAgLTI5NDUsOCArMjk0Niw4IEBAIGllZWU4MDIxMV9zdGFfc2Nhbl9yZXN1bHQoc3RydWN0
IG5ldF9kZXYKIAlpd2UudS5xdWFsLmxldmVsID0gYnNzLT5yc3NpOwogCWl3ZS51LnF1YWwubm9p
c2UgPSBic3MtPm5vaXNlOwogCWl3ZS51LnF1YWwudXBkYXRlZCA9IGxvY2FsLT53c3RhdHNfZmxh
Z3M7Ci0JY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX2V2ZW50KGN1cnJlbnRfZXYsIGVuZF9i
dWYsICZpd2UsCi0JCQkJCSAgSVdfRVZfUVVBTF9MRU4pOworCWN1cnJlbnRfZXYgPSBpd2Vfc3Ry
ZWFtX2FkZF9ldmVudChpbmZvLCBjdXJyZW50X2V2LCBlbmRfYnVmLAorCQkJCQkgICZpd2UsIElX
X0VWX1FVQUxfTEVOKTsKIAogCW1lbXNldCgmaXdlLCAwLCBzaXplb2YoaXdlKSk7CiAJaXdlLmNt
ZCA9IFNJT0NHSVdFTkNPREU7CkBAIC0yOTU1LDIyICsyOTU2LDIyIEBAIGllZWU4MDIxMV9zdGFf
c2Nhbl9yZXN1bHQoc3RydWN0IG5ldF9kZXYKIAllbHNlCiAJCWl3ZS51LmRhdGEuZmxhZ3MgPSBJ
V19FTkNPREVfRElTQUJMRUQ7CiAJaXdlLnUuZGF0YS5sZW5ndGggPSAwOwotCWN1cnJlbnRfZXYg
PSBpd2Vfc3RyZWFtX2FkZF9wb2ludChjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLCAiIik7CisJ
Y3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGluZm8sIGN1cnJlbnRfZXYsIGVuZF9i
dWYsICZpd2UsICIiKTsKIAogCWlmIChic3MgJiYgYnNzLT53cGFfaWUpIHsKIAkJbWVtc2V0KCZp
d2UsIDAsIHNpemVvZihpd2UpKTsKIAkJaXdlLmNtZCA9IElXRVZHRU5JRTsKIAkJaXdlLnUuZGF0
YS5sZW5ndGggPSBic3MtPndwYV9pZV9sZW47Ci0JCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2Fk
ZF9wb2ludChjdXJyZW50X2V2LCBlbmRfYnVmLCAmaXdlLAotCQkJCQkJICBic3MtPndwYV9pZSk7
CisJCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBjdXJyZW50X2V2LCBl
bmRfYnVmLAorCQkJCQkJICAmaXdlLCBic3MtPndwYV9pZSk7CiAJfQogCiAJaWYgKGJzcyAmJiBi
c3MtPnJzbl9pZSkgewogCQltZW1zZXQoJml3ZSwgMCwgc2l6ZW9mKGl3ZSkpOwogCQlpd2UuY21k
ID0gSVdFVkdFTklFOwogCQlpd2UudS5kYXRhLmxlbmd0aCA9IGJzcy0+cnNuX2llX2xlbjsKLQkJ
Y3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZp
d2UsCi0JCQkJCQkgIGJzcy0+cnNuX2llKTsKKwkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRk
X3BvaW50KGluZm8sIGN1cnJlbnRfZXYsIGVuZF9idWYsCisJCQkJCQkgICZpd2UsIGJzcy0+cnNu
X2llKTsKIAl9CiAKIAlpZiAoYnNzICYmIGJzcy0+c3VwcF9yYXRlc19sZW4gPiAwKSB7CkBAIC0y
OTg2LDggKzI5ODcsOCBAQCBpZWVlODAyMTFfc3RhX3NjYW5fcmVzdWx0KHN0cnVjdCBuZXRfZGV2
CiAJCWZvciAoaSA9IDA7IGkgPCBic3MtPnN1cHBfcmF0ZXNfbGVuOyBpKyspIHsKIAkJCWl3ZS51
LmJpdHJhdGUudmFsdWUgPSAoKGJzcy0+c3VwcF9yYXRlc1tpXSAmCiAJCQkJCQkJMHg3ZikgKiA1
MDAwMDApOwotCQkJcCA9IGl3ZV9zdHJlYW1fYWRkX3ZhbHVlKGN1cnJlbnRfZXYsIHAsCi0JCQkJ
CWVuZF9idWYsICZpd2UsIElXX0VWX1BBUkFNX0xFTik7CisJCQlwID0gaXdlX3N0cmVhbV9hZGRf
dmFsdWUoaW5mbywgY3VycmVudF9ldiwgcCwgZW5kX2J1ZiwKKwkJCQkJCSAmaXdlLCBJV19FVl9Q
QVJBTV9MRU4pOwogCQl9CiAJCWN1cnJlbnRfZXYgPSBwOwogCX0KQEAgLTMwMDAsOCArMzAwMSw4
IEBAIGllZWU4MDIxMV9zdGFfc2Nhbl9yZXN1bHQoc3RydWN0IG5ldF9kZXYKIAkJCWl3ZS5jbWQg
PSBJV0VWQ1VTVE9NOwogCQkJc3ByaW50ZihidWYsICJ0c2Y9JTAxNmxseCIsICh1bnNpZ25lZCBs
b25nIGxvbmcpKGJzcy0+dGltZXN0YW1wKSk7CiAJCQlpd2UudS5kYXRhLmxlbmd0aCA9IHN0cmxl
bihidWYpOwotCQkJY3VycmVudF9ldiA9IGl3ZV9zdHJlYW1fYWRkX3BvaW50KGN1cnJlbnRfZXYs
IGVuZF9idWYsCi0JCQkJCQkJICAmaXdlLCBidWYpOworCQkJY3VycmVudF9ldiA9IGl3ZV9zdHJl
YW1fYWRkX3BvaW50KGluZm8sIGN1cnJlbnRfZXYsCisJCQkJCQkJICBlbmRfYnVmLCAmaXdlLCBi
dWYpOwogCQkJa2ZyZWUoYnVmKTsKIAkJfQogCX0KQEAgLTMwMjAsMTUgKzMwMjEsMTUgQEAgaWVl
ZTgwMjExX3N0YV9zY2FuX3Jlc3VsdChzdHJ1Y3QgbmV0X2RldgogCQlpd2UuY21kID0gSVdFVkNV
U1RPTTsKIAkJc3ByaW50ZihidWYsICJiY25faW50PSVkIiwgYnNzLT5iZWFjb25faW50KTsKIAkJ
aXdlLnUuZGF0YS5sZW5ndGggPSBzdHJsZW4oYnVmKTsKLQkJY3VycmVudF9ldiA9IGl3ZV9zdHJl
YW1fYWRkX3BvaW50KGN1cnJlbnRfZXYsIGVuZF9idWYsICZpd2UsCi0JCQkJCQkgIGJ1Zik7CisJ
CWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChpbmZvLCBjdXJyZW50X2V2LCBlbmRf
YnVmLAorCQkJCQkJICAmaXdlLCBidWYpOwogCiAJCW1lbXNldCgmaXdlLCAwLCBzaXplb2YoaXdl
KSk7CiAJCWl3ZS5jbWQgPSBJV0VWQ1VTVE9NOwogCQlzcHJpbnRmKGJ1ZiwgImNhcGFiPTB4JTA0
eCIsIGJzcy0+Y2FwYWJpbGl0eSk7CiAJCWl3ZS51LmRhdGEubGVuZ3RoID0gc3RybGVuKGJ1Zik7
Ci0JCWN1cnJlbnRfZXYgPSBpd2Vfc3RyZWFtX2FkZF9wb2ludChjdXJyZW50X2V2LCBlbmRfYnVm
LCAmaXdlLAotCQkJCQkJICBidWYpOworCQljdXJyZW50X2V2ID0gaXdlX3N0cmVhbV9hZGRfcG9p
bnQoaW5mbywgY3VycmVudF9ldiwgZW5kX2J1ZiwKKwkJCQkJCSAgJml3ZSwgYnVmKTsKIAogCQlr
ZnJlZShidWYpOwogCQlicmVhazsKQEAgLTMwMzgsNyArMzAzOSw5IEBAIGllZWU4MDIxMV9zdGFf
c2Nhbl9yZXN1bHQoc3RydWN0IG5ldF9kZXYKIH0KIAogCi1pbnQgaWVlZTgwMjExX3N0YV9zY2Fu
X3Jlc3VsdHMoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgY2hhciAqYnVmLCBzaXplX3QgbGVuKQor
aW50IGllZWU4MDIxMV9zdGFfc2Nhbl9yZXN1bHRzKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsCisJ
CQkgICAgICAgc3RydWN0IGl3X3JlcXVlc3RfaW5mbyAqaW5mbywKKwkJCSAgICAgICBjaGFyICpi
dWYsIHNpemVfdCBsZW4pCiB7CiAJc3RydWN0IGllZWU4MDIxMV9sb2NhbCAqbG9jYWwgPSB3ZGV2
X3ByaXYoZGV2LT5pZWVlODAyMTFfcHRyKTsKIAljaGFyICpjdXJyZW50X2V2ID0gYnVmOwpAQCAt
MzA1MSw4ICszMDU0LDggQEAgaW50IGllZWU4MDIxMV9zdGFfc2Nhbl9yZXN1bHRzKHN0cnVjdCBu
ZQogCQkJc3Bpbl91bmxvY2tfYmgoJmxvY2FsLT5zdGFfYnNzX2xvY2spOwogCQkJcmV0dXJuIC1F
MkJJRzsKIAkJfQotCQljdXJyZW50X2V2ID0gaWVlZTgwMjExX3N0YV9zY2FuX3Jlc3VsdChkZXYs
IGJzcywgY3VycmVudF9ldiwKLQkJCQkJCSAgICAgICBlbmRfYnVmKTsKKwkJY3VycmVudF9ldiA9
IGllZWU4MDIxMV9zdGFfc2Nhbl9yZXN1bHQoZGV2LCBpbmZvLCBic3MsCisJCQkJCQkgICAgICAg
Y3VycmVudF9ldiwgZW5kX2J1Zik7CiAJfQogCXNwaW5fdW5sb2NrX2JoKCZsb2NhbC0+c3RhX2Jz
c19sb2NrKTsKIAlyZXR1cm4gY3VycmVudF9ldiAtIGJ1ZjsK
--------_4786D2F80000000062DA_MULTIPART_MIXED_--
