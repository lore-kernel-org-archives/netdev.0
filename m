From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: A question on the design of OVS GRE tunnel
Date: Mon, 8 Jul 2013 23:26:30 -0700
Message-ID: <CAEP_g=93ohj0u4uqiG4k_8kRFQYC71tNyri4xnRQcZCYNQhz=A@mail.gmail.com>
References: <1373277065.8227.26.camel@cr0>
	<CALnjE+q4L9Q8Ebj+O-D8xQHyzSo=FZrb7A-XVEGERzeN-MZMGQ@mail.gmail.com>
	<1373337666.4557.13.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
To: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1373337666.4557.13.camel@cr0>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 8, 2013 at 7:41 PM, Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, 2013-07-08 at 09:28 -0700, Pravin Shelar wrote:
>> On Mon, Jul 8, 2013 at 2:51 AM, Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> > However, I noticed there is some problem with such design:
>> >
>> > I saw very bad performance with the _default_ setup with OVS GRE. After
>> > digging it a little bit, clearly the cause is that OVS GRE tunnel adds
>> > an outer IP header and a GRE header for every packet that passed to it,
>> > which could result in a packet whose length is larger than the MTU of
>> > the uplink, therefore after the packet goes through OVS, it has to be
>> > fragmented by IP before going to the wire.
>> >
>> I do not understand what do you mean, gre packets greater than MTU
>> must be fragmented before sent on wire and it is done by GRE-GSO code.
>>
>
> Well, I said fragment, not segment. This is exactly why performance is
> so bad.
>
> In my _default_ setup, every net device on the path has MTU=1500,
> therefore, the packets coming out of a KVM guest can have length=1500,
> after they go through OVS GRE tunnel, their length becomes 1538 because
> of the added GRE header and IP header.
>
> After that, since the packets are not GSO (unless you pass vnet_hdr=on
> to KVM guest), the packets with length=1538 will be _fragmented_ by IP
> layer, since the dest uplink has MTU=1500 too. This is why I proposed to
> reuse GRO cell to merge the packets, which requires a netdev...

Large packets coming from a modern KVM guest will use TSO because this
is a huge performance win regardless of whether any tunneling is used.
It doesn't make any sense for the guest IP stack to take a stream of
packets, split them apart, merge them in the hypervisor stack, and
split them again before transmission. Any packets potentially worth
merging will almost certainly have originated as a single buffer in
the guest, so we should keep them together all the way from the guest
to the GSO/TSO layer.

The real problem is that the requested MSS size is not correct. In the
"best" situation we would first segment the packet to the requested
size, add the tunnel headers, and then fragment. However, it looks to
me like the original size is being carried all the way to the GSO
code, which will then generate packets that are greater than the MTU.
Both of these can likely be improved upon by either convincing the
guest to automatically use a lower MSS or adjusting it ourselves.
X-CudaMail-Whitelist-To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
