From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: Re: [PATCH] samples/bpf: Fix test_maps/bpf_get_next_key() test
Date: Fri, 23 Jan 2015 15:13:46 +0100
Message-ID: <20150123151346.28ae0d6c@holzheu>
References: <CAADnVQ+3exrhp8bS50HEnMrYdg4i3+K7c6ewNZHRkBqtW-uwOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAADnVQ+3exrhp8bS50HEnMrYdg4i3+K7c6ewNZHRkBqtW-uwOA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Jan 2015 09:32:43 -0800
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Thu, Jan 22, 2015 at 8:01 AM, Michael Holzheu
> <holzheu@linux.vnet.ibm.com> wrote:
> > Looks like the "test_maps" test case expects to get the keys in
> > the wrong order when iterating over the elements:
> >
> > test_maps: samples/bpf/test_maps.c:79: test_hashmap_sanity: Assertion
> > `bpf_get_next_key(map_fd, &key, &next_key) == 0 && next_key == 2' failed.
> > Aborted
> >
> > Fix this and test for the correct order.
> 
> that will break this test on x86...
> we need to understand first why the order of two elements
> came out different on s390...
> Could it be that jhash() produced different hash for the same
> values on x86 vs s390 ?

Yes I think jhash() produces different results for input > 12 bytes
on big and little endian machines because of the following code
in include/linux/jhash.h:

        while (length > 12) {
                a += __get_unaligned_cpu32(k);
                b += __get_unaligned_cpu32(k + 4);
                c += __get_unaligned_cpu32(k + 8);
                __jhash_mix(a, b, c);
                length -= 12;
                k += 12;
        }

The contents of "k" is directly used as u32 and the result
of "__get_unaligned_cpu32(k)" is different for big and
little endian.

Michael
