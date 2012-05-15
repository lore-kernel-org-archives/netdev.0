From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [V2 PATCH 4/9] macvtap: zerocopy: set SKBTX_DEV_ZEROCOPY only
 when skb is built successfully
Date: Tue, 15 May 2012 10:44:03 -0700
Message-ID: <1337103843.8220.22.camel@oc3660625478.ibm.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <20120502034206.11782.91643.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120502034206.11782.91643.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-02 at 11:42 +0800, Jason Wang wrote:
> Current the SKBTX_DEV_ZEROCOPY is set unconditionally after
> zerocopy_sg_from_iovec(), this would lead NULL pointer when macvtap
> fails to build zerocopy skb because destructor_arg was not
> initialized. Solve this by set this flag after the skb were built
> successfully.

I thought this flag was needed for zerocopy skb free even in err case.
I've checked it back again, it's OK to move the flag after the skb
successfully built. Or we can fix it by modify skb free with
destructor_arg NULL check as below:
...
skb_release_data() {
...
                if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
                        struct ubuf_info *uarg;

                        uarg = skb_shinfo(skb)->destructor_arg;
                        if (uarg && uarg->callback)
                                uarg->callback(uarg);
                }

...
}
Thanks
Shirley
