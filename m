From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: warnings in git-wireless
Date: Tue, 5 Jun 2007 02:06:14 -0700
Message-ID: <20070605020614.3f06b2ab.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


i386 allmodconfig isn't that hard, guys.

drivers/net/wireless/mac80211/zd1211rw/zd_mac.c:600: warning: 'fill_rt_header' defined but not used
drivers/net/wireless/mac80211/iwlwifi/iwl-4965.c: In function 'iwl_hw_tx_queue_free_tfd':
drivers/net/wireless/mac80211/iwlwifi/iwl-4965.c:964: warning: left shift count >= width of type
drivers/net/wireless/mac80211/iwlwifi/iwl-4965.c: In function 'iwl_hw_tx_queue_attach_buffer_to_tfd':
drivers/net/wireless/mac80211/iwlwifi/iwl-4965.c:2041: warning: left shift count >= width of type
drivers/net/wireless/mac80211/iwlwifi/iwl-4965.c:2041: warning: left shift count >= width of type
drivers/net/wireless/mac80211/iwlwifi/iwl-4965.c:2047: warning: left shift count >= width of type
drivers/net/wireless/mac80211/iwlwifi/iwl-4965.c:2050: warning: left shift count >= width of type

With some trepidation I looked in just that header.


> #define iwl_get_bits(src, pos, len)   \
> ({                                    \
> 	u32 __tmp = le32_to_cpu(src); \
> 	__tmp >>= pos;                \
> 	__tmp &= (1UL << len) - 1;    \
> 	__tmp;                        \
> })

Can be a inlined C function.  Should be commented.

> #define iwl_set_bits(dst, pos, len, val)                 \
> ({                                                       \
> 	u32 __tmp = le32_to_cpu(*dst);                   \
>         __tmp &= ~((1UL << (pos+len)) - (1 << pos));     \
> 	__tmp |= (val & ((1UL << len) - 1)) << pos;      \
>         *dst = cpu_to_le32(__tmp);                       \
> })

Ditto.  Whitespace broken.

> #define _IWL_SET_BITS(s, d, o, l, v) \
>         iwl_set_bits(&s.d, o, l, v)
> 
> #define IWL_SET_BITS(s, sym, v) \
>         _IWL_SET_BITS((s), IWL_ ## sym ## _SYM, IWL_ ## sym ## _POS, IWL_ ## sym ## _LEN, (v))
> 
> #define _IWL_GET_BITS(s, v, o, l) \
>         iwl_get_bits(s.v, o, l)
> 
> #define IWL_GET_BITS(s, sym) \
>         _IWL_GET_BITS((s), IWL_ ## sym ## _SYM, IWL_ ## sym ## _POS, IWL_ ## sym ## _LEN)

Shudder.

> /*
>  * make C=2 CF=-Wall will complain if you use ARRAY_SIZE on global data
>  */
> #define GLOBAL_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

This is identical to ARRAY_SIZE.

And if there's some problem with ARRAY_SIZE then fix ARRAY_SIZE!  Don't go 
off and create some private thing and leave everyone else twisting in the
wind.

> /* Debug and printf string expansion helpers for printing bitfields */
> #define BIT_FMT8 "%c%c%c%c-%c%c%c%c"
> #define BIT_FMT16 BIT_FMT8 ":" BIT_FMT8
> #define BIT_FMT32 BIT_FMT16 " " BIT_FMT16
> 
> #define BITC(x,y) (((x>>y)&1)?'1':'0')
> #define BIT_ARG8(x) \
> BITC(x,7),BITC(x,6),BITC(x,5),BITC(x,4),\
> BITC(x,3),BITC(x,2),BITC(x,1),BITC(x,0)
> 
> #define BIT_ARG16(x) \
> BITC(x,15),BITC(x,14),BITC(x,13),BITC(x,12),\
> BITC(x,11),BITC(x,10),BITC(x,9),BITC(x,8),\
> BIT_ARG8(x)
> 
> #define BIT_ARG32(x) \
> BITC(x,31),BITC(x,30),BITC(x,29),BITC(x,28),\
> BITC(x,27),BITC(x,26),BITC(x,25),BITC(x,24),\
> BITC(x,23),BITC(x,22),BITC(x,21),BITC(x,20),\
> BITC(x,19),BITC(x,18),BITC(x,17),BITC(x,16),\
> BIT_ARG16(x)

None of the above is appropriate to a driver-private header.

> #define KELVIN_TO_CELSIUS(x) ((x)-273)

Nor is that.

> #define IEEE80211_CHAN_W_RADAR_DETECT 0x00000010
> 
> static inline struct ieee80211_conf *ieee80211_get_hw_conf(struct ieee80211_hw
> 							   *hw)
> {
> 	return &hw->conf;
> }
> 
> static inline const struct ieee80211_hw_mode *iwl_get_hw_mode(struct iwl_priv
> 							      *priv, int mode)
> {
> 	int i;
> 
> 	for (i = 0; i < 3; i++)
> 		if (priv->modes[i].mode == mode)
> 			return &priv->modes[i];
> 
> 	return NULL;
> }

Far too large to inline, has five callsites.

> #define WLAN_FC_GET_TYPE(fc)    (((fc) & IEEE80211_FCTL_FTYPE))
> #define WLAN_FC_GET_STYPE(fc)   (((fc) & IEEE80211_FCTL_STYPE))
> #define WLAN_GET_SEQ_FRAG(seq)  ((seq) & 0x000f)
> #define WLAN_GET_SEQ_SEQ(seq)   ((seq) >> 4)

These don't need to be macros

> #define QOS_CONTROL_LEN 2
> 
> static inline u16 *ieee80211_get_qos_ctrl(struct ieee80211_hdr *hdr)
> {
> 	int hdr_len = ieee80211_get_hdrlen(hdr->frame_control);
> 	if (hdr->frame_control & IEEE80211_STYPE_QOS_DATA)
> 		return (u16 *) ((u8 *) hdr + (hdr_len) - QOS_CONTROL_LEN);
> 	return NULL;
> }

Two callsites, too large to inline.

> #define IEEE80211_STYPE_BACK_REQ	0x0080
> #define IEEE80211_STYPE_BACK		0x0090
> 
> #define ieee80211_is_back_request(fc) \
> 	((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_CTL) && \
> 	(WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_BACK_REQ))
> 
> #define ieee80211_is_probe_response(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>     ( WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_PROBE_RESP ))
> 
> #define ieee80211_is_probe_request(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>     ( WLAN_FC_GET_STYPE(fc) ==IEEE80211_STYPE_PROBE_REQ ))
> 
> #define ieee80211_is_beacon(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>     ( WLAN_FC_GET_STYPE(fc) ==IEEE80211_STYPE_BEACON ))
> 
> #define ieee80211_is_atim(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>     ( WLAN_FC_GET_STYPE(fc) ==IEEE80211_STYPE_ATIM ))
> 
> #define ieee80211_is_management(fc) \
>    (WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT)
> 
> #define ieee80211_is_control(fc) \
>    (WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_CTL)
> 
> #define ieee80211_is_data(fc) \
>    (WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_DATA)
> 
> #define ieee80211_is_assoc_request(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>    (WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_ASSOC_REQ))
> 
> #define ieee80211_is_assoc_response(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>    (WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_ASSOC_RESP))
> 
> #define ieee80211_is_auth(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>    (WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_ASSOC_REQ))
> 
> #define ieee80211_is_deauth(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>    (WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_ASSOC_REQ))
> 
> #define ieee80211_is_disassoc(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>    (WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_ASSOC_REQ))
> 
> #define ieee80211_is_reassoc_request(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>    (WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_REASSOC_REQ))
> 
> #define ieee80211_is_reassoc_response(fc) \
>    ((WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_MGMT) && \
>    (WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_REASSOC_RESP))

None of the above should be macros.

> static inline int iwl_is_empty_essid(const char *essid, int essid_len)
> {
> 	/* Single white space is for Linksys APs */
> 	if (essid_len == 1 && essid[0] == ' ')
> 		return 1;
> 
> 	/* Otherwise, if the entire essid is 0, we assume it is hidden */
> 	while (essid_len) {
> 		essid_len--;
> 		if (essid[essid_len] != '\0')
> 			return 0;
> 	}
> 
> 	return 1;
> }

The above large function gets inlined into iwl_escape_essid()

> static inline int iwl_check_bits(unsigned long field, unsigned long mask)
> {
> 	return ((field & mask) == mask) ? 1 : 0;
> }
> 
> static inline const char *iwl_escape_essid(const char *essid, u8 essid_len)
> {
> 	static char escaped[IW_ESSID_MAX_SIZE * 2 + 1];
> 	const char *s = essid;
> 	char *d = escaped;
> 
> 	if (iwl_is_empty_essid(essid, essid_len)) {
> 		memcpy(escaped, "<hidden>", sizeof("<hidden>"));
> 		return escaped;
> 	}
> 
> 	essid_len = min(essid_len, (u8) IW_ESSID_MAX_SIZE);
> 	while (essid_len--) {
> 		if (*s == '\0') {
> 			*d++ = '\\';
> 			*d++ = '0';
> 			s++;
> 		} else {
> 			*d++ = *s++;
> 		}
> 	}
> 	*d = '\0';
> 	return escaped;
> }

This now-enormous function has three callsites.  Madness!

> static inline unsigned long elapsed_jiffies(unsigned long start,
> 					    unsigned long end)
> {
> 	if (end > start)
> 		return end - start;
> 
> 	return end + (MAX_JIFFY_OFFSET - start);
> }

Whatever this uncommented function is doing, it is not appropriate to a
per-driver header file.

> #include <linux/ctype.h>

This should go at the top of the file.

> static inline int snprint_line(char *buf, size_t count,
> 			       const u8 * data, u32 len, u32 ofs)
> {
> 	int out, i, j, l;
> 	char c;
> 
> 	out = snprintf(buf, count, "%08X", ofs);
> 
> 	for (l = 0, i = 0; i < 2; i++) {
> 		out += snprintf(buf + out, count - out, " ");
> 		for (j = 0; j < 8 && l < len; j++, l++)
> 			out +=
> 			    snprintf(buf + out, count - out, "%02X ",
> 				     data[(i * 8 + j)]);
> 		for (; j < 8; j++)
> 			out += snprintf(buf + out, count - out, "   ");
> 	}
> 	out += snprintf(buf + out, count - out, " ");
> 	for (l = 0, i = 0; i < 2; i++) {
> 		out += snprintf(buf + out, count - out, " ");
> 		for (j = 0; j < 8 && l < len; j++, l++) {
> 			c = data[(i * 8 + j)];
> 			if (!isascii(c) || !isprint(c))
> 				c = '.';
> 
> 			out += snprintf(buf + out, count - out, "%c", c);
> 		}
> 
> 		for (; j < 8; j++)
> 			out += snprintf(buf + out, count - out, " ");
> 	}
> 
> 	return out;
> }

We're kidding.  Three callsites!

Dump the whole thing, use lib/hexdump.c.

> #ifdef CONFIG_IWLWIFI_DEBUG
> static inline void printk_buf(int level, const void *p, u32 len)
> {
> 	const u8 *data = p;
> 	char line[81];
> 	u32 ofs = 0;
> 	if (!(iwl_debug_level & level))
> 		return;
> 
> 	while (len) {
> 		snprint_line(line, sizeof(line), &data[ofs],
> 			     min(len, 16U), ofs);
> 		printk(KERN_DEBUG "%s\n", line);
> 		ofs += 16;
> 		len -= min(len, 16U);
> 	}
> }

This is even huger and it has six callsites.

> #else
> #define printk_buf(level, p, len) do {} while (0)
> #endif
> 
> #endif				/* __iwl_helpers_h__ */

And that's one file out of a 3MB diff.

Please, don't anybody dare think about thinking about letting this anywhere
near mainline until it has had a thorough review.  Or at least, a little bit
of review.

<goes back to fixing all the new compile errors and warnings>
