From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2] net: bluetooth: hci_sock: Use 'const void *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Mon, 02 Feb 2015 13:20:17 -0800
Message-ID: <1422912017.30476.28.camel@perches.com>
References: <54CFE8BE.5030700@sunrus.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen Gang S <gang.chen-/B7AUNIrSHOPt1CcHtbs0g@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54CFE8BE.5030700-/B7AUNIrSHOPt1CcHtbs0g@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-02-03 at 05:14 +0800, Chen Gang S wrote:
> hci_test_bit() does not modify 2nd parameter, so it is better to let it
> be constant, or may cause build warning. The related warning (with
> allmodconfig under xtensa):
[]
> diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
[]
> @@ -46,7 +46,7 @@ struct hci_pinfo {
>  	unsigned short    channel;
>  };
>  
> -static inline int hci_test_bit(int nr, void *addr)
> +static inline int hci_test_bit(int nr, const void *addr)
>  {
>  	return *((__u32 *) addr + (nr >> 5)) & ((__u32) 1 << (nr & 31));
>  }

It's probably better to use const __u32 * here too, but the
real thing I wonder is whether or not there's an issue with
one of the 2 uses of this function.

One of them passes a unsigned long *, the other a u32 *.

$ git grep -w hci_test_bit
net/bluetooth/hci_sock.c:static inline int hci_test_bit(int nr, void *addr)
net/bluetooth/hci_sock.c:       if (!hci_test_bit(flt_event, &flt->event_mask))
net/bluetooth/hci_sock.c:                    !hci_test_bit(ocf & HCI_FLT_OCF_BITS,
net/bluetooth/hci_sock.c-                                  &hci_sec_filter.ocf_mask[ogf])) &&

hci_sec_filter.ocf_mask is __u32
but flt->event_mask is unsigned long.

Any possible issue here on 64-bit systems?

---

$ git grep -A4 "struct hci_filter {"
include/net/bluetooth/hci_sock.h:struct hci_filter {
include/net/bluetooth/hci_sock.h-       unsigned long type_mask;
include/net/bluetooth/hci_sock.h-       unsigned long event_mask[2];
include/net/bluetooth/hci_sock.h-       __le16 opcode;
include/net/bluetooth/hci_sock.h-};

---

static bool is_filtered_packet(struct sock *sk, struct sk_buff *skb)
{
	struct hci_filter *flt;
[...]
	if (!hci_test_bit(flt_event, &flt->event_mask))
		return true;
