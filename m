From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH v2 net-next 6/6] net: switchdev: extract struct switchdev_obj_*
Date: Wed, 30 Sep 2015 07:58:38 -0700
Message-ID: <CAE4R7bAVWg3qiN6gw9yEeBHuggZdYccndiNk8LzXw6tqfseLMA@mail.gmail.com>
References: <1443542838-19234-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1443542838-19234-7-git-send-email-vivien.didelot@savoirfairelinux.com> <20150930103618.GC2098@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150930103618.GC2098@nanopsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 3:36 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Sep 29, 2015 at 06:07:18PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>>Now that switchdev and its drivers directly use specific switchdev_obj_*
>>structures, move them out of the switchdev_obj union and get rif of this
>>outer structure.
>>
>>Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>>---
>> include/net/switchdev.h | 53 ++++++++++++++++++++++++-------------------------
>> 1 file changed, 26 insertions(+), 27 deletions(-)
>>
>>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>index bcadac3..e11425e 100644
>>--- a/include/net/switchdev.h
>>+++ b/include/net/switchdev.h
>>@@ -64,30 +64,29 @@ enum switchdev_obj_id {
>>       SWITCHDEV_OBJ_PORT_FDB,
>> };
>>
>>-struct switchdev_obj {
>>-      enum switchdev_obj_id id;
>>-      int (*cb)(struct switchdev_obj *obj);
>>-      union {
>>-              struct switchdev_obj_vlan {             /* PORT_VLAN */
>>-                      u16 flags;
>>-                      u16 vid_begin;
>>-                      u16 vid_end;
>>-              } vlan;
>>-              struct switchdev_obj_ipv4_fib {         /* IPV4_FIB */
>>-                      u32 dst;
>>-                      int dst_len;
>>-                      struct fib_info *fi;
>>-                      u8 tos;
>>-                      u8 type;
>>-                      u32 nlflags;
>>-                      u32 tb_id;
>>-              } ipv4_fib;
>>-              struct switchdev_obj_fdb {              /* PORT_FDB */
>>-                      const unsigned char *addr;
>>-                      u16 vid;
>>-                      u16 ndm_state;
>>-              } fdb;
>>-      } u;
>>+/* SWITCHDEV_OBJ_PORT_VLAN */
>>+struct switchdev_obj_vlan {
>>+      u16 flags;
>>+      u16 vid_begin;
>>+      u16 vid_end;
>>+};
>>+
>>+/* SWITCHDEV_OBJ_IPV4_FIB */
>>+struct switchdev_obj_ipv4_fib {
>>+      u32 dst;
>>+      int dst_len;
>>+      struct fib_info *fi;
>>+      u8 tos;
>>+      u8 type;
>>+      u32 nlflags;
>>+      u32 tb_id;
>>+};
>>+
>>+/* SWITCHDEV_OBJ_PORT_FDB */
>>+struct switchdev_obj_fdb {
>>+      const unsigned char *addr;
>>+      u16 vid;
>>+      u16 ndm_state;
>> };
>
>
> I don't like these structs being passed down as a "void *". I think that
> we should have some "common" struct for these objects, event if it would
> be empty and pass it down. "void *" does not look good at all, does not
> tell the reader what that param is about. How about:
>
> struct switchdev_obj {
> };
>
> struct switchdev_obj_vlan {
>         struct switchdev_obj obj;
>         u16 flags;
>         u16 vid_begin;
>         u16 vid_end;
> };
> #define SWITCHDEV_OBJ_VLAN(obj) \
>         container_of(obj, struct switchdev_obj_vlan, obj)
>
> /* SWITCHDEV_OBJ_IPV4_FIB */
> struct switchdev_obj_ipv4_fib {
>         struct switchdev_obj obj;
>         u32 dst;
>         int dst_len;
>         struct fib_info *fi;
>         u8 tos;
>         u8 type;
>         u32 nlflags;
>         u32 tb_id;
> };
> #define SWITCHDEV_OBJ_IPV4_FIB(obj)     \
>         container_of(obj, struct switchdev_obj_ipv4_fib, obj)
>
> /* SWITCHDEV_OBJ_PORT_FDB */
> struct switchdev_obj_fdb {
>         struct switchdev_obj obj;
>         const unsigned char *addr;
>         u16 vid;
>         u16 ndm_state;
> };
> #define SWITCHDEV_OBJ_FDB(obj)  \
>         container_of(obj, struct switchdev_obj_fdb, obj)
>
>
> then pass struct switchdev_obj *obj down to drivers and in driver, get
> original object by SWITCHDEV_OBJ_* ?


Yes, I agree with Jiri, keep the struct switchdev_obj, use it within
each specific struct, and pass struct switchdev * in core funcs rather
than void *.
