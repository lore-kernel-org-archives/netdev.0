From: "David B. Robins" <linux@davidrobins.net>
Subject: Re: [REGRESSION] asix: Lots of =?UTF-8?Q?asix=5Frx=5Ffixup=28=29?=
 =?UTF-8?Q?=20errors=20and=20slow=20transmissions?=
Date: Tue, 03 May 2016 10:42:46 -0400
Message-ID: <87ed4c76328ed9dc5591359ea0e98ab9@i4031.net>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	Dean Jenkins <Dean_Jenkins@mentor.com>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	Guodong Xu <guodong.xu@linaro.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-05-03 00:55, John Stultz wrote:
> In testing with HiKey, we found that since commit 3f30b158eba5c60
> (asix: On RX avoid creating bad Ethernet frames), we're seeing lots of
> noise during network transfers:
> 
> [  239.027993] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
> synchronisation was lost, remaining 988
> [  239.037310] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0x54ebb5ec, offset 4
> [  239.045519] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0xcdffe7a2, offset 4
> [  239.275044] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
> synchronisation was lost, remaining 988
> [  239.284355] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0x1d36f59d, offset 4
> [  239.292541] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0xaef3c1e9, offset 4
> [  239.518996] asix 1-1.1:1.0 eth0: asix_rx_fixup() Data Header
> synchronisation was lost, remaining 988
> [  239.528300] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0x2881912, offset 4
> [  239.536413] asix 1-1.1:1.0 eth0: asix_rx_fixup() Bad Header Length
> 0x5638f7e2, offset 4
> 
> And network throughput ends up being pretty bursty and slow with a
> overall throughput of at best ~30kB/s.
> 
> Looking through the commits since the v4.1 kernel where we didn't see
> this, I narrowed the regression down, and reverting the following two
> commits seems to avoid the problem:
> 
> 6a570814cd430fa5ef4f278e8046dcf12ee63f13 asix: Continue processing URB
> if no RX netdev buffer
> 3f30b158eba5c604b6e0870027eef5d19fc9271d asix: On RX avoid creating
> bad Ethernet frames
> 
> With these reverted, we don't see all the error messages, and we see
> better ~1.1MB/s throughput (I've got a mouse plugged in, so I think
> the usb host is only running at "full-speed" mode here).

I don't think the first one is giving you problems (except as triggered 
by the second) but I had concerns about the second myself (and emailed 
the author off-list, but received no reply), and we did not take that 
commit for our own product.

Specifically, the second change, 3f30... (original patch: 
https://www.mail-archive.com/netdev@vger.kernel.org/msg80720.html) (1) 
appears to do the exact opposite of what it claims, i.e., instead of 
"resync if this looks like a header", it does "resync if this does NOT 
look like a (packet) header", where "looks like a header" means "bits 
0-10 (size) are equal to the bitwise-NOT of bits 16-26", and (2) can 
happen by coincidence for 1/2048 32-bit values starting a continuation 
URB (easy to hit dealing with large volumes of video data as we were). 
It appears to expect the header for every URB whereas the rest of the 
code at least expects it only once per network packet (look at following 
code that only reads it for remaining == 0).

So that change made no sense to me, but I don't have significant kernel 
dev experience. Effectively it will drop/truncate every (2047/2048) 
split (longer than an URB) packet, and report an error for the second 
URB and then again for treating said second URB as a first URB for a 
packet. I would expect your problems will go away just removing the 
second change. You could also change the != to == in "if (size != ...)" 
but then you'd still have 1/2048 (depending on data patterns) false 
positives.

> This worries me some, as the patches seem to describe trying to fix
> the issue they seem to cause, so I suspect a revert isn't the correct
> solution, but am not sure why we're having such trouble and the patch
> authors did not.  I'd be happy to do further testing of patches if
> folks have any ideas.
> 
> Originally Reported-by: Yongqin Liu <yongqin.liu@linaro.org>
> 
> thanks
> -john

David
