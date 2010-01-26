From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to	hw_breakpoint
Date: Tue, 26 Jan 2010 11:16:42 +0900
Message-ID: <4B5E508A.1030305@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E3F2C.2010702@zytor.com> <4B5E4E12.7060900@kernel.org> <20100126020452.GB19799@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, davem@davemloft.net,
	netdev@vger.kernel.org, x86@kernel.org, mingo@redhat.com,
	dan.j.williams@intel.com, borislav.petkov@amd.com,
	ying.huang@intel.com, lenb@kernel.org, neilb@suse.de,
	cl@linux-foundation.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:53659 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545Ab0AZCMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 21:12:34 -0500
In-Reply-To: <20100126020452.GB19799@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2010 11:04 AM, Al Viro wrote:
> On Tue, Jan 26, 2010 at 11:06:10AM +0900, Tejun Heo wrote:
>> Hello,
>>
>> On 01/26/2010 10:02 AM, H. Peter Anvin wrote:
>>> A cast (using __typeof__) combined with an address space override?
>>
>> That still puts the address specification at the wrong level.  The
>> problem is that the __typeof__ would be an array type which itself
>> doesn't have address space set but its members are in address space 3.
>> So, you need to get *inside* the array type def to change that.  :-(
> 
> Could you post the actual definitions in one piece?  Would be easier to
> discuss what's going on...

Here it is.

# define RELOC_HIDE(ptr, off)					\
  ({ unsigned long __ptr;					\
     __ptr = (unsigned long) (ptr);				\
    (typeof(ptr)) (__ptr + (off)); })

#define __verify_pcpu_ptr(ptr)	do {					\
	const void __percpu *__vpp_verify = (typeof(ptr))NULL;		\
	(void)__vpp_verify;						\
} while (0)

/* Weird cast keeps both GCC and sparse happy. */
#define SHIFT_PERCPU_PTR(__p, __offset)	({				\
	__verify_pcpu_ptr((__p));					\
	RELOC_HIDE((typeof(*(__p)) __kernel __force *)(__p), (__offset)); \
})

#define per_cpu(var, cpu) \
	(*SHIFT_PERCPU_PTR(&(var), per_cpu_offset(cpu)))

Thanks.

-- 
tejun
