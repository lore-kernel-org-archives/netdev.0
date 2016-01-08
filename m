From: David Herrmann <dh.herrmann@gmail.com>
Subject: Re: [PATCH RESEND] bluetooth:hicp:Fix error handling in the function hidp_connection_del
Date: Fri, 8 Jan 2016 13:16:13 +0100
Message-ID: <CANq1E4R7TtQ2ckSF3GYHMoDihCfDKO5EX8kQGHH=VB9xrdhtjQ@mail.gmail.com>
References: <1451422549-22071-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, tedd.an@intel.com,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451422549-22071-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Tue, Dec 29, 2015 at 9:55 PM, Nicholas Krause <xerofoify@gmail.com> wrote:
> This fixes error handling in the function hidp_connection_del to
> properly check if the internal call to hidp_send_ctrl_message has
> failed by returning a error code and if so immediately return this
> error code to the caller of hidp_connection_del to signal that a
> failed call has occurred that needs to be handled by this function's
> caller.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  net/bluetooth/hidp/core.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
>
> diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
> index f1a117f..13aa6d0 100644
> --- a/net/bluetooth/hidp/core.c
> +++ b/net/bluetooth/hidp/core.c
> @@ -1360,6 +1360,7 @@ int hidp_connection_del(struct hidp_conndel_req *req)
>  {
>         u32 valid_flags = BIT(HIDP_VIRTUAL_CABLE_UNPLUG);
>         struct hidp_session *session;
> +       int err;
>
>         if (req->flags & ~valid_flags)
>                 return -EINVAL;
> @@ -1368,14 +1369,16 @@ int hidp_connection_del(struct hidp_conndel_req *req)
>         if (!session)
>                 return -ENOENT;
>
> -       if (req->flags & BIT(HIDP_VIRTUAL_CABLE_UNPLUG))
> -               hidp_send_ctrl_message(session,
> -                                      HIDP_TRANS_HID_CONTROL |
> -                                        HIDP_CTRL_VIRTUAL_CABLE_UNPLUG,
> -                                      NULL, 0);
> -       else
> +       if (req->flags & BIT(HIDP_VIRTUAL_CABLE_UNPLUG)) {
> +               err = hidp_send_ctrl_message(session,
> +                                            HIDP_TRANS_HID_CONTROL |
> +                                            HIDP_CTRL_VIRTUAL_CABLE_UNPLUG,
> +                                            NULL, 0);
> +               if (err)
> +                       return err;

This leaks a reference to 'session'.

> +       } else {
>                 l2cap_unregister_user(session->conn, &session->user);
> -
> +       }
>         hidp_session_put(session);

I'm not very convinced that this is a good idea. Transmission is
handled async, hence all you catch here is OOM. Nothing interesting
can be returned, and there's nothing sane the caller can do to handle
the error. I'd keep the code as is.

Thanks
David

>
>         return 0;
> --
> 2.1.4
>
