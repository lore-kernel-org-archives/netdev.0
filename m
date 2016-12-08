From: Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH v2 4/4] vsock: cancel packets when failing to connect
Date: Thu, 8 Dec 2016 18:37:14 +0800
Message-ID: <CA+a=Yy5LD4Fiyi0QbT9jJPEVXPzOXDUa4+-uD+vR3PeJ79pb8A@mail.gmail.com>
References: <1481123652-80603-1-git-send-email-bergwolf@gmail.com>
 <1481123652-80603-5-git-send-email-bergwolf@gmail.com> <20161208092446.GB10780@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stefan Hajnoczi <stefanha@redhat.com>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jorgen Hansen <jhansen@vmware.com>
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20161208092446.GB10780@stefanha-x1.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 8, 2016 at 5:24 PM, Stefan Hajnoczi <stefanha@gmail.com> wrote:
> On Wed, Dec 07, 2016 at 11:14:12PM +0800, Peng Tao wrote:
>> Otherwise we'll leave the packets queued until releasing vsock device.
>> E.g., if guest is slow to start up, resulting ETIMEDOUT on connect, guest
>> will get the connect requests from failed host sockets.
>>
>> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
>> Signed-off-by: Peng Tao <bergwolf@gmail.com>
>> ---
>>  include/linux/virtio_vsock.h            | 7 +++++++
>>  net/vmw_vsock/af_vsock.c                | 7 +++++++
>>  net/vmw_vsock/virtio_transport_common.c | 7 -------
>>  3 files changed, 14 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
>> index b92e88d..ff6850a 100644
>> --- a/include/linux/virtio_vsock.h
>> +++ b/include/linux/virtio_vsock.h
>> @@ -156,4 +156,11 @@ void virtio_transport_inc_tx_pkt(struct virtio_vsock_sock *vvs, struct virtio_vs
>>  u32 virtio_transport_get_credit(struct virtio_vsock_sock *vvs, u32 wanted);
>>  void virtio_transport_put_credit(struct virtio_vsock_sock *vvs, u32 credit);
>>
>> +static inline const struct virtio_transport *virtio_transport_get_ops(void)
>> +{
>> +     const struct vsock_transport *t = vsock_core_get_transport();
>> +
>> +     return container_of(t, struct virtio_transport, transport);
>> +}
>> +
>>  #endif /* _LINUX_VIRTIO_VSOCK_H */
>> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
>> index 8a398b3..ebb50d6 100644
>> --- a/net/vmw_vsock/af_vsock.c
>> +++ b/net/vmw_vsock/af_vsock.c
>> @@ -104,6 +104,7 @@
>>  #include <linux/unistd.h>
>>  #include <linux/wait.h>
>>  #include <linux/workqueue.h>
>> +#include <linux/virtio_vsock.h>
>>  #include <net/sock.h>
>>  #include <net/af_vsock.h>
>>
>> @@ -1105,6 +1106,7 @@ static void vsock_connect_timeout(struct work_struct *work)
>>  {
>>       struct sock *sk;
>>       struct vsock_sock *vsk;
>> +     int cancel = 0;
>>
>>       vsk = container_of(work, struct vsock_sock, dwork.work);
>>       sk = sk_vsock(vsk);
>> @@ -1115,8 +1117,11 @@ static void vsock_connect_timeout(struct work_struct *work)
>>               sk->sk_state = SS_UNCONNECTED;
>>               sk->sk_err = ETIMEDOUT;
>>               sk->sk_error_report(sk);
>> +             cancel = 1;
>>       }
>>       release_sock(sk);
>> +     if (cancel)
>> +             virtio_transport_get_ops()->cancel_pkt(vsk);
>
> This doesn't work with the VMCI transport.  Remember af_vsock.c is
> common code shared by all transports.
>
> You need to add a struct vsock_transport->cancel_pkt() callback instead
> os a struct virtio_transport->cancel_pkt() callback.  And you need to
> handle the case where cancel_pkt == NULL if you don't implement it for
> VMCI.
>
I see. Thanks for reviewing! I'll fix it and resend later.

Cheers,
Tao
