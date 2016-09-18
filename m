From: Tariq Toukan via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 04/11] net/mlx5e: Build RX SKB on
	demand
Date: Sun, 18 Sep 2016 18:46:39 +0300
Message-ID: <d24e3fab-0f57-ea02-4a9f-38364c60dd51@mellanox.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-5-git-send-email-saeedm@mellanox.com>
	<20160907173449.GB64688@ast-mbp.thefacebook.com>
Reply-To: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Saeed Mahameed
	<saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160907173449.GB64688-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On 07/09/2016 8:34 PM, Alexei Starovoitov wrote:
> On Wed, Sep 07, 2016 at 03:42:25PM +0300, Saeed Mahameed wrote:
>> For non-striding RQ configuration before this patch we had a ring
>> with pre-allocated SKBs and mapped the SKB->data buffers for
>> device.
>>
>> For robustness and better RX data buffers management, we allocate a
>> page per packet and build_skb around it.
>>
>> This patch (which is a prerequisite for XDP) will actually reduce
>> performance for normal stack usage, because we are now hitting a bottleneck
>> in the page allocator. A later patch of page reuse mechanism will be
>> needed to restore or even improve performance in comparison to the old
>> RX scheme.
>>
>> Packet rate performance testing was done with pktgen 64B packets on xmit
>> side and TC drop action on RX side.
>>
>> CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
>>
>> Comparison is done between:
>>   1.Baseline, before 'net/mlx5e: Build RX SKB on demand'
>>   2.Build SKB with RX page cache (This patch)
>>
>> Streams    Baseline    Build SKB+page-cache    Improvement
>> -----------------------------------------------------------
>> 1          4.33Mpps      5.51Mpps                27%
>> 2          7.35Mpps      11.5Mpps                52%
>> 4          14.0Mpps      16.3Mpps                16%
>> 8          22.2Mpps      29.6Mpps                20%
>> 16         24.8Mpps      34.0Mpps                17%
> Impressive gains for build_skb. I think it should help ip forwarding too
> and likely tcp_rr. tcp_stream shouldn't see any difference.
> If you can benchmark that along with pktgen+tc_drop it would
> help to better understand the impact of the changes.
Why do you expect an improvement in tcp_rr?
I don't see such in my tests.
>
