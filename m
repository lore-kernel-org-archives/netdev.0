From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Thu, 17 Mar 2011 20:28:47 -0700
Message-ID: <1300418927.3255.62.camel@localhost.localdomain>
References: <1300320775.3255.34.camel@localhost.localdomain>
	 <20110317050242.GC32049@redhat.com>
	 <1300375115.3255.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1300375115.3255.45.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-17 at 08:18 -0700, Shirley Ma wrote:
> On Thu, 2011-03-17 at 07:02 +0200, Michael S. Tsirkin wrote:
> > So, this just tries to make sure there's enough space for
> > max packet in the ring, if not - drop and return OK.
> > Why bother checking beforehand though?
> > If that's what we want to do, we can just call add_buf and see
> > if it fails?
> 
> In add_buf, there is an additional kick, see below. I added check
> capacity to avoid this, thought it would be better performance. I will
> retest it w/i add_buf to see the performance difference.
> 
>         if (vq->num_free < out + in) {
>                 pr_debug("Can't add buf len %i - avail = %i\n",
>                          out + in, vq->num_free);
>                 /* FIXME: for historical reasons, we force a notify
> here
> if
>                  * there are outgoing parts to the buffer.  Presumably
> the
>                  * host should service the ring ASAP. */
>                 if (out)
>                         vq->notify(&vq->vq);
>                 END_USE(vq);
>                 return -ENOSPC;
>         }
> 

More test results:

UDP_STREAM test results (% is guest vcpu, guest has 2 vpus):

Send(netperf)
----

size	2.6.38-rc8	2.6.38-rc8+	2.6.38-rc8
			addbuf failure	check capacity
-----------------------------------------------------
1K	1541.0/50.14%	2169.1/50.03%	3018.9/50%
2K	1649.7/33.74%	3362.6/50.18%	4518.8/50.47%	
4K	2957.8/44.83%	5965.9/50.03%	9592.5/50%
8K	3788/39.01%	9852.8/50.25%	15483.8/50%
16K	4736.1/34.13%	14946.5/50.01%	21645.0/50%

Recv(netserver w/i recv errors)
----
1K	1541/8.36%	1554.4/9.67%	1675.1/11.26%
2K	1649.7/33.4%	1945.5/5.59%	2160.6/5.99%
4K	2556.3/5.07%	3044.8/7.12%	3118.9/7.86%
8K	3775/39.01%	4361/9/9.14%	4017.1/7.89%
16K	4466.4/8.56%	4435.2/10.95%	4446.8/9.92%

TCP_STREAM test results (% is guest vcpu, guest has two vcpus):

size	2.6.38-rc8	2.6.38-rc8+	2.6.38-rc8
			addbuf failure	check capacity
------------------------------------------------------
1K	2381.10/42.49%	5686.01/50.08%	5599.15/50.42%
2K	3205.08/49.18%	8675.93/48.59%	9241.86/48.42%	
4K	5231.24/34.12%	9309.67/42.07%	9321.87/40.94%
8K	7952.74/35.85%	9001.95/38.26%	9265.45/37.63%
16K	8260.68/35.07%	7911.52/34.35%	8310.29/34.28%
64K	9103.75/28.98%	9219.12/31.52%	9094.38/29.44%

qemu-kvm host cpu utilization also saved for both addbuf failure and
check capacity patches, vhost cpu utilization are similar in all case.

Looks like the additional guest notify in add_buf doesn't cost that much
than I thought to be.

Thanks
Shirley

