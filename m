From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [RFC PATCH] net: Require socket to allow XPS to set queue mapping
Date: Wed, 21 Sep 2016 11:07:30 -0400
Message-ID: <CAF=yD-+UsUxM+iUicQLATd6B_6JmRovo3KGQrhQToQiXQ-2hQw@mail.gmail.com>
References: <147215300812.3936.8031402062962283044.stgit@ahduyck-desk.amr.corp.intel.com>
 <1472154564.14381.160.camel@edumazet-glaptop3.roam.corp.google.com>
 <3fd7a334-c660-6e31-1466-27b08a2c983f@hpe.com> <1472159297.14381.162.camel@edumazet-glaptop3.roam.corp.google.com>
 <3a1d23f2-d2c6-8d28-96cc-1b25b61b948c@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:32930 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754998AbcIUPIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:08:11 -0400
Received: by mail-yw0-f195.google.com with SMTP id g192so3010041ywh.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 08:08:11 -0700 (PDT)
In-Reply-To: <3a1d23f2-d2c6-8d28-96cc-1b25b61b948c@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 5:28 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 08/25/2016 02:08 PM, Eric Dumazet wrote:
>>
>> When XPS was submitted, it was _not_ enabled by default and 'magic'
>>
>> Some NIC vendors decided it was a good thing, you should complain to
>> them ;)
>
>
> I kindasorta am with the emails I've been sending to netdev :)  And also
> hopefully precluding others going down that path.

I recently came across another effect of configuring devices at
ndo_open. The behavior of `ip link set dev ${dev} down && ip link set
dev ${dev} up` is no longer consistent across devices. Drivers that
call netif_set_xps_queue overwrite a user supplied xps configuration,
others leave it in place.

This is easily demonstrated by adding this snippet to the loopback driver:

+static int loopback_dev_open(struct net_device *dev)
+{
+       cpumask_t mask;
+
+       cpumask_clear(&mask);
+       cpumask_set_cpu(0, &mask);
+
+       return netif_set_xps_queue(dev, &mask, 0);
+}
+
 static void loopback_dev_free(struct net_device *dev)
 {
        free_percpu(dev->lstats);
@@ -158,6 +168,7 @@ static void loopback_dev_free(struct net_device *dev)

 static const struct net_device_ops loopback_ops = {
        .ndo_init      = loopback_dev_init,
+       .ndo_open       = loopback_dev_open,


and running

fp=/sys/class/net/lo/queues/tx-0/xps_cpus

cat ${fp}
echo 8 > ${fp}
cat ${fp}
ip link set dev lo down
ip link set dev lo up
cat ${fp}

On a vanilla kernel, the output is {0, 8, 8} : the user-supplied xps
setting persists
With the patch, it is {1, 8, 1} : the driver sets, and resets, xps

A third patch that adds netif_set_xps_queue to loopback_dev_init gives
{1, 8, 8}. That is arguably the preferred behavior (sidestepping the
issue of whether device driver initialization is a good thing in
itself): init with a sane default, but do not override user
preference.

The fm10k and i40e drivers makes the call conditional on
test_and_set_bit(__FM10K_TX_XPS_INIT_DONE), so probably already
implement those semantics. In which case other drivers should probably
be updated to do the same. If all drivers are essentially trying to
set the same basic load balancing policy, this could also be lifted
out of drivers into __dev_open for consistency and code deduplication.

I'm pointing this out less for changing this xps feature, than as a
subtle effect to be aware of with any subsequent device driver policy
patches.
