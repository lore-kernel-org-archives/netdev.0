From: John Stultz <john.stultz@linaro.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow transmissions
Date: Fri, 6 May 2016 13:57:22 -0700
Message-ID: <CALAqxLXsna_em_5w8yonXUCcMwbOGknYtL5LhqYCHUK9LKFr0A@mail.gmail.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
	<87ed4c76328ed9dc5591359ea0e98ab9@i4031.net>
	<57291539.6080405@mentor.com>
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
In-Reply-To: <57291539.6080405@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 3, 2016 at 2:16 PM, Dean Jenkins <Dean_Jenkins@mentor.com> wrote:
>
> [  239.027993] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
> synchronisation was lost, remaining 988
>
> This error message consistently shows the remaining value to be 988, at
> least for the 3 examples provided by John. This does not suggest a random
> failure unless there are other examples of a non 988 remaining value error
> message. 988 is well within a Ethernet frame length so seems to be valid.
>
> I think a good step would be to add some debug to print the rx->remaining
> value at entry to asix_rx_fixup_internal(). This would generate a lot of
> debug but a pattern of the values might emerge.


So I've been trying to add some print messages here to better
understand whats going on.

Again, I'm a bit new to this code, so forgive me for my lack of
understanding things. Since the remaining value seems to be key, I
tried to look around and figure out where it was being set. It seems
like its only set in this function, is that right?  So this made me
guess something might be happening in a previous iteration that was
causing this to trigger.

I added some debug prints to every time we set the remaining value, or
modify it, as well as to print the value if we enter the fixup
function with a non-zero remaining value.

When we set the remaining value, usually its to 1514, when the skblen is 1518.

However, right before we catch the problem, I see this:


[   84.844337] JDB set remaining to 1514 (skblen: 1518)
[   84.844379] JDB set remaining to 1514 (skblen: 1518)
[   84.844429] JDB set remaining to 1514 (skblen: 1518)
[   84.844458] JDB set remaining to 1514 (skblen: 1518)
[   84.844483] JDB set remaining to 1514 (skblen: 1518)
[   84.844507] JDB set remaining to 1514 (skblen: 1518)
[   84.844559] JDB set remaining to 1514 (skblen: 2048)
[   84.844583] JDB set remaining to 1514 (skblen: 2048)
[   84.844595] JDB: 1514 > 2048 - 1522
[   84.844606] JDB: dropping remaining by 526
[   84.844624] asix_rx_fixup_internal()  remaining: 988,  skb->len: 2048
[   84.844672] asix 1-5:1.0 eth1: asix_rx_fixup() Data Header
synchronisation was lost, remaining 988
[   84.844945] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0xdd5f8f9b, offset 4
[   84.845217] asix 1-5:1.0 eth1: asix_rx_fixup() Bad Header Length
0x3ce1ad3c, offset 4
[   84.845451] JDB set remaining to 1514 (skblen: 1518)
[   84.845485] JDB set remaining to 1514 (skblen: 1518)
[   84.845511] JDB set remaining to 1514 (skblen: 1518)
[   84.851003] JDB set remaining to 1514 (skblen: 1518)


So when the issue happens, it seems to be due to an larger then usual
skb (2048). The first time through the wile loop we set the remaining
to 1514, but offset is fairly small, so we set copy_length to 1514,
and clear remaining. The offset is bumped by a little more then the
copy length and we loop again.  Then the second time through we set
remaining to 1514, but since offset is bigger now, the if
(rx->remaining > skb->len - offset)  case is true..

This is where it feels a little strange..

We calculate the copy_length as the difference between the offset and
the skb->len (so how much is left in the skb, which is 526), then
decrement remaining by that amount.  Not really sure what remaining
(now 988) is supposed to represent here. We copy the 526 bytes, and
then exit the loop.

Now the next time we are called, we enter and we have a remaining
value still of 988, which triggers the header synchronization error
path.

Now, I'm not sure if the remainder handling logic is sane, or if the
skb->len being 2048 is problematic, or what.  The skb->lens can vary
in sizes, usually 1518 during high throughput, but I've seen 1588,
1640, and other larger numbers that don't trigger the same problem.

ie:
[  106.946473] JDB set remaining to 1514 (skblen: 1518)
[  106.946525] JDB set remaining to 1514 (skblen: 1640)
[  106.946546] JDB set remaining to 118 (skblen: 1640)
[  106.946586] JDB set remaining to 1514 (skblen: 1518)


So yea.. maybe that will help clue things in a bit? I'm still a bit lost. :)

thanks
-john
