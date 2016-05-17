From: John Stultz <john.stultz@linaro.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow transmissions
Date: Mon, 16 May 2016 17:10:21 -0700
Message-ID: <CALAqxLURsrwngUCsMpwihjdKsEU40UsTQ6nZQqNm9WTVZ_6-kA@mail.gmail.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
	<87ed4c76328ed9dc5591359ea0e98ab9@i4031.net>
	<57291539.6080405@mentor.com>
	<CALAqxLXsna_em_5w8yonXUCcMwbOGknYtL5LhqYCHUK9LKFr0A@mail.gmail.com>
	<5733AB6C.2060204@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David B. Robins" <linux@davidrobins.net>,
	lkml <linux-kernel@vger.kernel.org>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	Guodong Xu <guodong.xu@linaro.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>
To: Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5733AB6C.2060204@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 11, 2016 at 3:00 PM, Dean Jenkins <Dean_Jenkins@mentor.com> wrote:
>
> Your observations are consistent with missing URBs from the USB host
> controller.
>
> Here is a summary of what I think is happening in your case:
>
> Good case:
> URB #1: 1514 octets of 1514 Ethernet frame (A)
> URB #2: 1514 octets of 1514 Ethernet frame (B) + 526 octets of 1514 Ethernet
> frame (C)
> URB #3: 988 octets of 1514 Ethernet frame (C)
> URB #4: 1514 octets of 1514 Ethernet frame (D)
>
> Therefore, Ethernet frame (C) is spanning URBs #2 and #3.
>
> Bad case, URB #3 is lost:
> URB #1: 1514 octets of 1514 Ethernet frame (A)
> URB #2: 1514 octets of 1514 Ethernet frame (B) + 526 octets of 1514 Ethernet
> frame (C)
> Remaining is 988
> URB #4: 1514 octets of 1514 Ethernet frame (D)
>
> But when URB #4 is analysed the 32-bit Header word is not found after 988
> octets in the URB buffer so "sync lost".
> The end of Ethernet frame (C) is missing so drop the Ethernet frame.
> Now look at the start of the URB #4 buffer and find a 32-bit header word so
> Ethernet frame (D) can be consumed.
>
> So I think the commit is acting as intended and you are suffering from lost
> URBs.

No. I went digging on this for a bit longer, and it looks like its
just that you're calculating the offset wrong in your check.

I was wondering why without your patch we wouldn't see "Bad Header
Length" messages, since if the remaining was 988 and the skb->len was
2048 as seen in my logs, without your patch we should copy the 988
bytes out clear remaining and then continue processing the rest of the
skb, which calculates the header and checks the size. If we really
lost the URB, we should throw an error at that point, since really
we'd be midway through the following frame.  But we just don't see
that with your patch removed.

Looking more closely, in the main loop, we do:
    (where offset is zero, or set to "offset += (copy_length + 1) &
0xfffe" in the previous loop)
    rx->header = get_unaligned_le32(skb->data +
                                                                offset);
    offset += sizeof(u32);

But your check calculates:
    offset = ((rx->remaining + 1) & 0xfffe) + sizeof(u32);
    rx->header = get_unaligned_le32(skb->data + offset);

Adding some debug logic to check those offset calculation used to find
rx->header, the one in your code is always too large by sizeof(u32).

So removing the extra addition in your offset calculation seems to
solve this for me.

I'll send out a patch here shortly.

thanks
-john
