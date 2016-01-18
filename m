From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] af_packet: Raw socket destruction warning fix
Date: Mon, 18 Jan 2016 11:29:26 +0100
Message-ID: <569CBE86.8030107@iogearbox.net>
References: <1453099068-39022-1-git-send-email-maninder1.s@samsung.com> <569CB419.6050102@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
	eyal.birger@gmail.com, tklauser@distanz.ch,
	fruggeri@aristanetworks.com, dwmw2@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pankaj.m@samsung.com, gh007.kim@samsung.com,
	hakbong5.lee@samsung.com, Vaneet Narang <v.narang@samsung.com>
To: Maninder Singh <maninder1.s@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <569CB419.6050102@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/18/2016 10:44 AM, Daniel Borkmann wrote:
> On 01/18/2016 07:37 AM, Maninder Singh wrote:
>> Receieve queue is not purged when socket dectruction is called
>> results in kernel warning because of non zero sk_rmem_alloc.
>>
>> WARNING: at net/packet/af_packet.c:1142 packet_sock_destruct
>>
>> Backtrace:
>> WARN_ON(atomic_read(&sk->sk_rmem_alloc)
>> packet_sock_destruct
>> __sk_free
>> sock_wfree
>> skb_release_head_state
>> skb_release_all
>> __kfree_skb
>> net_tx_action
>> __do_softirq
>> run_ksoftirqd
>>
>> Signed-off-by: Vaneet Narang <v.narang@samsung.com>
>> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
>
> Thanks for the fix. While it fixes the WARN_ON(), I believe some more
> investigation is needed here on why it is happening:
>
> We call first into packet_release(), which removes the socket hook from
> the kernel (unregister_prot_hook()), later calls synchronize_net() to
> make sure no more skbs will come in. The receive queue is purged right
> after the synchronize_net() already.
>
> packet_sock_destruct() will be called afterwards, when there are no more
> refs on the socket anymore and no af_packet skbs in tx waiting for completion.

(...and in your above case, there seem to have been some skbs in tx from
{t,}packet_snd(), as we call __sk_free() via kfree_skb() (-> sock_wfree()).)

> Only then, in sk_destruct(), we'll call into packet_sock_destruct().
>
> So, eventually double purging the sk_receive_queue seems not the right
> thing to do at first look, and w/o any deeper analysis in the commit description.
>
> Could you look a bit further into the issue? Do you have a reproducer to
> trigger it?
>
> Thanks,
> Daniel
