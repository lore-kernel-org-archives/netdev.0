From: James Morris <jmorris@redhat.com>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 11:05:26 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0410311004290.677-100000@thoron.boston.redhat.com>
References: <1099030958.4944.148.camel@uganda>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <cryptoapi@lists.logix.cz>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <1099030958.4944.148.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Please review and comment, I am open for discussion.

Here is an initial review, based on the updated patch posted my Michael 
Ludwig.

It's great to see this code being written rather than just discussed.

Have you seen earlier discussions on hardware crypto requirements, some of
which are summarized at http://samba.org/~jamesm/crypto/hardware_notes.txt
, and further discussed on the cryptoapi list?

Briefly, the main components required for hardware crypto support are:

a) Crypto driver API

This is for registering all types of crypto drivers, including the
software algorithms and various hardware devices.  A feature of this API
would be to communicate various capabilities and features of the driver to
the core crypto code.  Your code appears to at least partially provide
such an API, although I'm not clear on exactly what it's suitable for all
types of crypto drivers.  It looks to be heading in the right direction.

The existing software drivers should be converted to the new API and the 
old API removed.


b) Kernel crypto API

This refers to the API used by general kernel code which needs to invoke
crypto processing.  Currently we have a simple synchronous API.

For hardware support we need an asynchronous API, which for example, would 
allow a caller to:

 - allocate a crypto session, specifying preferences, algorithms to be 
   used etc.
 - manage crypto session parameters (e.g. key info etc).
 - batch and submit crypto operations
 - receive completed operation results

I would imagine that we would deprecate the existing sync API, convert 
existing users to the async API then eventually remove the sync API.

This areas needs more analysis and development.


c) Async engine: scheduling/batching/routing etc.

This seems to be the core of what you've developed so far.  I'm not sure 
if we need pluggable load balancers.  How would the sysadmin select the 
correct one?  The simpler this code is the better.


d) User API via filesystem.

The user API issue has been discussed on the crypto API list previously.  
I have outlined some ideas for a pseudo filesytem API, although there are 
still some issues to be resolved.


Overall I think it's a good start.  There are some chicken & egg type 
problems when you don't have GPL drivers, hardware or an existing async 
API, so I'd imagine that this will all continue to evolve:  with more 
hardware we can write/incorporate more drivers, with more drivers we can 
further refine the async support and API etc.


Code Review.

Firstly, please follow Documentation/CodingStyle more closely.  Perhaps 
run Lindent over your code and have a look at the differences.

It's much easier to review and test the code if it is supplied as a patch
against a recent Linus kernel, rather than a collection of files.  If you 
update your tree, please regenerate the patch rather than just send new 
files.

Here are some issues that I noticed:


What is main_crypto_device?  Is this a placeholder for when there are no 
other devices registered?

Async & sync drivers need to both be treated as crypto drivers.


static inline void crypto_route_free(struct crypto_route *rt)
{
        crypto_device_put(rt->dev);
        rt->dev = NULL;
        kfree(rt);
}

Why do you set rt->dev to NULL here?  It should not still be referenceable 
at this point.


__crypto_route_del() etc:

Why are you rolling your own list management and not using the list.h 
functions?


+struct crypto_device_stat
+{
+       __u64                   scompleted;
+       __u64                   sfinished;
...

Please see how networking stats are implemented (e.g. netif_rx_stats) and 
previous netdev discussions on 64-bit counters.  Please only use __u64 and 
similar when exporting structures to userspace.


Struct ordring:

+       u16                     priority;
+
+       u64                     id;
+       u64                     dev_id;
+
+       u32                     flags;

The struct will be better aligned if you put the smaller fields first
(although there may be cases where you want cache-hot items at the front).  
Also, why the gaps between fields?



__crypto_device_add():

Please split device initialization and linking into distinct functions.  
The initialization should probably be done in e.g. crypto_device_alloc() 
instead of this.


+       struct crypto_device *__dev, *n;

Please use a name other than __dev here.  Underscored variable names are 
generally used for things like local variables in macros, not local 
temporary variables in functions.


void crypto_device_remove(struct crypto_device *dev):

Don't loop waiting for the device to become free.  Also, you're scheduling 
inside a spinlock.  This code needs to be re-thought in general to ensure 
that a device is always destroyed safely.


crypto_lb_unregister():

I think this has already been raised.  Please don't do things like this.  
I'm not sure we need loadable load balancers yet, although in any case, 
if we always need one loaded, then make a default one that cannot be 
unloaded or replaces the last lb.


Where is crypto_session_alloc() used?  It's difficult to evaluate the code
more deeply without seeing such primitives in use.


Thanks for doing this work and hope this helps,


- James
-- 
James Morris
<jmorris@redhat.com>
