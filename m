From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/6] test_bpf: allow tests to specify an skb fragment.
Date: Mon, 03 Aug 2015 17:29:40 +0200
Message-ID: <55BF88E4.2050307@iogearbox.net>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr> <1438610528-14245-3-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Nicolas Schichan <nschichan@freebox.fr>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438610528-14245-3-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/03/2015 04:02 PM, Nicolas Schichan wrote:
> This introduce a new test->aux flag (FLAG_SKB_FRAG) to tell the
> populate_skb() function to add a fragment to the test skb containing
> the data specified in test->frag_data).
>
> Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

I'm good with this change here, just a comment below in general.

>   enum {
>   	CLASSIC  = BIT(6),	/* Old BPF instructions only. */
> @@ -81,6 +83,7 @@ struct bpf_test {
>   		__u32 result;
>   	} test[MAX_SUBTESTS];
>   	int (*fill_helper)(struct bpf_test *self);
> +	__u8 frag_data[MAX_DATA];
>   };

We now have 286 tests, which is awesome!

Perhaps, we need to start thinking of a better test description method
soonish as the test_bpf.ko module grew to ~1.6M, i.e. whenever we add
to struct bpf_test, it adds memory overhead upon all test cases.

>   /* Large test cases need separate allocation and fill handler. */
> @@ -4525,6 +4528,10 @@ static struct sk_buff *populate_skb(char *buf, int size)
>
>   static void *generate_test_data(struct bpf_test *test, int sub)
>   {
> +	struct sk_buff *skb;
> +	struct page *page;
> +	void *ptr;
> +
>   	if (test->aux & FLAG_NO_DATA)
>   		return NULL;
>
> @@ -4532,7 +4539,36 @@ static void *generate_test_data(struct bpf_test *test, int sub)
>   	 * subtests generate skbs of different sizes based on
>   	 * the same data.
>   	 */
> -	return populate_skb(test->data, test->test[sub].data_size);
> +	skb = populate_skb(test->data, test->test[sub].data_size);
> +	if (!skb)
> +		return NULL;
> +
> +	if (test->aux & FLAG_SKB_FRAG) {

Really minor nit: declaration of page, ptr could have been only in this block.
