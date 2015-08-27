From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: add support for %s specifier to
 bpf_trace_printk()
Date: Thu, 27 Aug 2015 16:06:14 -0700
Message-ID: <55DF97E6.9050108@plumgrid.com>
References: <1440656819-25622-1-git-send-email-ast@plumgrid.com>
 <20150827.153409.893765406170260565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, rostedt@goodmis.org, wangnan0@huawei.com,
	hekuang@huawei.com, daniel@iogearbox.net,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150827.153409.893765406170260565.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/27/15 3:34 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Wed, 26 Aug 2015 23:26:59 -0700
>
>> +/* similar to strncpy_from_user() but with extra checks */
>> +static void probe_read_string(char *buf, int size, long unsafe_ptr)
>> +{
>> +	char dst[4];
>> +	int i = 0;
>> +
>> +	size--;
>> +	for (;;) {
>> +		if (probe_kernel_read(dst, (void *) unsafe_ptr, 4))
>> +			break;
>
> I don't think this does the right thing when the string is not a multiple
> of 3 and ends at the last byte of a page that ends a valid region of
> kernel memory.
>
> Seeing this kind of error makes me skeptical to the overall value of
> optimizing this :-/

I've considered the case when first two bytes are valid, but the
other two are in a different page. In such case the probe_read_string()
will trim the string and won't be printing these two valid bytes.
I think that's very rare, so I'm picking higher performance for common
case. The strings over > 64 bytes also will be trimmed to 64.
It's a debugging facility, so I felt that's ok.
Fair or you still think it should be per byte copy?
