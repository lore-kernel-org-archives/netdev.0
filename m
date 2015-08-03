From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: [PATCH 2/6] test_bpf: allow tests to specify an skb fragment.
Date: Mon, 03 Aug 2015 18:38:33 +0200
Message-ID: <55BF9909.4070704@freebox.fr>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr> <1438610528-14245-3-git-send-email-nschichan@freebox.fr> <55BF88E4.2050307@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:34416 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824AbbHCQif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2015 12:38:35 -0400
In-Reply-To: <55BF88E4.2050307@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2015 05:29 PM, Daniel Borkmann wrote:
> On 08/03/2015 04:02 PM, Nicolas Schichan wrote:
> We now have 286 tests, which is awesome!
> 
> Perhaps, we need to start thinking of a better test description method
> soonish as the test_bpf.ko module grew to ~1.6M, i.e. whenever we add
> to struct bpf_test, it adds memory overhead upon all test cases.

Indeed, test_bpf.ko is turning quite large (1.4M when compiled for ARM).

It looks like gzip is able to do wonders on the module though as I end up with
a 94.7K test_bpf.ko.gz file and if the modutils are compiled with
--enable-zlib, it will be gunziped automatically before being loaded to the
kernel.

I think that marking tests[] array as __initdata will help with the runtime
memory use if someone forgets to rmmod the test_bpf module after a completely
successful run.

>>   /* Large test cases need separate allocation and fill handler. */
>> @@ -4525,6 +4528,10 @@ static struct sk_buff *populate_skb(char *buf, int size)
>>
>>   static void *generate_test_data(struct bpf_test *test, int sub)
>>   {
>> +    struct sk_buff *skb;
>> +    struct page *page;
>> +    void *ptr;
>> +
>>       if (test->aux & FLAG_NO_DATA)
>>           return NULL;
>>
>> @@ -4532,7 +4539,36 @@ static void *generate_test_data(struct bpf_test
>> *test, int sub)
>>        * subtests generate skbs of different sizes based on
>>        * the same data.
>>        */
>> -    return populate_skb(test->data, test->test[sub].data_size);
>> +    skb = populate_skb(test->data, test->test[sub].data_size);
>> +    if (!skb)
>> +        return NULL;
>> +
>> +    if (test->aux & FLAG_SKB_FRAG) {
> 
> Really minor nit: declaration of page, ptr could have been only in this block.

I can certainly move the ptr declaration in the if block, but I'd rather leave
the struct page there to avoid to have the cleanup code awkwardly sitting in
the if block if that's okay with you.

Thanks,

-- 
Nicolas Schichan
Freebox SAS
